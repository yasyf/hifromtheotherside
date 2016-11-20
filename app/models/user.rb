class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:facebook]

  validates :desired, presence: true, if: :filled_out_form?
  validates :supported, presence: true, if: :filled_out_form?
  validates :email, presence: true, if: :filled_out_form?
  validates :first_name, presence: true, if: :filled_out_form?
  validates :last_name, presence: true, if: :filled_out_form?
  validates :background, presence: true, if: :filled_out_form?
  validates :subscribe, inclusion: [true, false]

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

  def filled_out_form?
    desired.present? || supported.present?
  end

  def name
    "#{first_name} #{last_name}"
  end

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

  def self.export(scope=where(subscribe: true), options={})
    scope.as_json({methods: [:name], only: [:email, :desired, :supported]}.reverse_merge(options))
  end
end
