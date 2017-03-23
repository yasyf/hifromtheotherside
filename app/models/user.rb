require 'open-uri'

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:facebook]

  validates :desired, presence: true, if: :completed?
  validates :supported, presence: true, if: :completed?
  validates :email, presence: true, if: :completed?
  validates :first_name, presence: true, if: :completed?
  validates :last_name, presence: true, if: :completed?
  validates :background, presence: true, if: :completed?
  validates :subscribe, inclusion: [true, false]
  validates :zip, numericality: { only_integer: true, allow_blank: true }

  KEY_WORDS = %w(
    chef diplomat fireman teacher veteran vet
    engineer pilot artist dancer entrepreneur
    psychologist doctor science physics biology
    chemistry nonprofit computer musician writer
    business author spy government singer geek
    startup astronaut lawyer policeman ballet
    magician actor actress president surgeon
    christian muslim jew
    york francisco boston
  )

  SUPPORTED_CANDIDATES = {
    trump: "Donald Trump",
    clinton: "Hillary Clinton",
    stein: "Jill Stein",
    johnson: "Gary Johnson",
    other: "Other",
  }.with_indifferent_access

  DESIRED_CANDIDATES = {
    trump: "a Donald Trump supporter",
    clinton: "a Hillary Clinton supporter",
    independent: "an independent candidate supporter",
    anyone: "anyone who didn't support my candidate",
  }.with_indifferent_access

  enum supported: SUPPORTED_CANDIDATES.keys, _prefix: true
  enum desired: DESIRED_CANDIDATES.keys, _prefix: true

  scope :with_pairings, -> { joins('LEFT OUTER JOIN pairings ON pairings.user_1_id = users.id OR pairings.user_2_id = users.id') }
  scope :paired, -> { with_pairings.where('pairings.id IS NOT NULL').order(:id).select('DISTINCT ON (users.id) users.*') }
  scope :unpaired, -> { with_pairings.where('pairings.id IS NULL') }
  scope :completed, -> { where.not(desired: nil, supported: nil) }
  scope :zip_starts_with, ->(zip_prefix) { where("users.zip LIKE '#{zip_prefix}%'") }

  def self.from_omniauth(auth)
    graph = Koala::Facebook::API.new(auth.credentials.token)
    info = graph.get_object("me", fields: 'first_name, last_name, email')

    from_email = where(email: info['email']).first
    if from_email.present?
      from_email.update! provider: auth.provider, uid: auth.uid
      return from_email
    end

    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.assign_attributes info.slice('first_name', 'last_name', 'email')
      user.password = Devise.friendly_token[0,20]
    end
  end

  def self.in_zip_range(start, finish, scope=all)
    scope.select {|u| u.zip.to_i >= start && u.zip.to_i <= finish }
  end

  def self.import(csv_url, header_map)
    CSV.foreach(open(csv_url).path, headers: true) do |row|
      attrs = row.map { |k,v| [header_map[k], v] if header_map.include?(k) }.compact.to_h
      attrs[:supported] = SUPPORTED_CANDIDATES.invert[attrs[:supported]] || :other
      attrs[:desired] = DESIRED_CANDIDATES.invert[attrs[:desired]] || :anyone
      if attrs[:name].present?
        name = attrs.delete(:name).split(' ')
        attrs[:first_name], attrs[:last_name] = name.shift, name.join(' ')
      end
      user = where(email: attrs[:email]).first_or_initialize
      user.assign_attributes attrs
      user.password = Devise.friendly_token[0,20]
      user.save!
    end
  end

  def self.export(scope=where(subscribe: true), options={})
    scope.as_json({methods: [:name], only: [:email, :desired, :supported]}.reverse_merge(options))
  end

  def self.state_counts(scope=where.not(zip: ""))
    states = where.not(zip: "").map { |u| ZipCodes.identify(u.zip) }.compact.map { |h| h[:state_code] }
    states.each_with_object(Hash.new(0)) { |state, counts| counts[state] += 1 }
  end

  def self.searchable_columns
    [:email, :first_name, :last_name]
  end

  def completed?
    desired.present? && supported.present?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def paired_users
    pairings.map { |pair| pair.user_1 == self ? pair.user_2 : pair.user_1 }
  end

  def possible_pairing
    @possible_pairing ||= begin
      other = Rails.cache.fetch("#{cache_key}/pairing") { find_pairing }
      refresh = other.blank? || User.where(id: other.id).count == 0 || other.paired?
      other = Rails.cache.fetch("#{cache_key}/pairing", force: true) { find_pairing } if refresh
      other
    end
  end

  def supported_nice
    SUPPORTED_CANDIDATES[supported]
  end

  def paired?
    pairings.present?
  end

  def pairings
    @pairings ||= Pairing.where(user_1: self).or(Pairing.where(user_2: self))
  end

  def third_party?
    !supported.to_sym.in? [:trump, :clinton]
  end

  def nearest_starbucks
    return nil unless zip.present?
    Rails.cache.fetch("#{cache_key}/nearest_starbucks", expires_in: 1.week) { Location.new(zip).nearest_starbucks }
  end

  private

  def key_words
    KEY_WORDS.select { |word| background.downcase.include?(word) }.shuffle
  end

  def order_by_zip(scope)
    scope.order("@(COALESCE(NULLIF(zip, ''), '1000000')::int - #{zip.to_i})")
  end

  def find_pairing
    scope = self.class
      .unpaired
      .where(supported: desired_to_supported)
      .where(desired: supported_to_desired)
      .where.not(id: self.id)

    # Similar zip
    if self.zip.present?
      zip_scope = scope.zip_starts_with(self.zip.to_s[0..-3])
      scope = zip_scope if zip_scope.count > 0
    end

    # Combinations of keywords
    words = key_words
    while words.present?
      search = scope.advanced_search(background: words.join('&'))
      return order_by_zip(search).first if search.present?
      words.pop
    end

    # Each individual keyword
    key_words.each do |word|
      search = scope.basic_search(background: word)
      return order_by_zip(search).first if search.present?
    end

    # Fallback to closest
    order_by_zip(scope).first
  end

  def desired_to_supported
    case desired.to_sym
    when :trump
      :trump
    when :clinton
      :clinton
    when :independent
      [:stein, :johnson]
    when :anyone
      # If willing to talk to anyone, pair with Clinton (#37)
      :clinton
    end
  end

  def supported_to_desired
    desired =
      case supported.to_sym
      when :trump
        :trump
      when :clinton
        :clinton
      when :stein, :johnson
        :independent
      end
    [desired, :anyone].compact
  end
end
