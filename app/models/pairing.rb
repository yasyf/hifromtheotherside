class Pairing < ApplicationRecord
  belongs_to :user_1, class_name: "User"
  belongs_to :user_2, class_name: "User"

  validates :user_2, uniqueness: { scope: :user_1 }

  enum status: [:unknown, :bounced, :delivered, :opened, :clicked]
  has_many :gift_cards

  def self.pair!(user_1, user_2)
    return unless user_1 != user_2
    user_1_id = [user_1.id, user_2.id].min
    user_2_id = [user_1.id, user_2.id].max
    pairing = create! user_1_id: user_1_id, user_2_id: user_2_id
    email = pairing.email!
    pairing.update! message_id: email.message_id
    pairing
  end

  def self.from_event(params)
    message_id = params['Message-Id'] ||
                params['message-id'] ||
                (params['message-headers'] && params['message-headers']['Message-Id']) ||
                (params[:message] && params[:message][:headers] && params[:message][:headers]['message-id'])
    by_message_id = where(message_id: message_id)
    by_recipient = User.where(email: params[:recipient])
    by_message_id.first || by_recipient.first&.pairings&.last
  end

  def self.process_event_backlog!
    client = Mailgun::Client.new ENV['MAILGUN_API_KEY']
    response = client.get("#{ENV['MAILGUN_DOMAIN']}/events", limit: 300).to_h!
    response['items'].sort_by { |e| e['timestamp'] }.each do |event|
      params = event.with_indifferent_access
      from_event(params)&.process_event!(params)
    end
  end

  def email!
    locations = user_locations
    PairingMailer.paired_email(self, locations).deliver_now
    if locations[0][:city] == locations[1][:city]
      PairingMailer.user_1_starbucks_email(self).deliver_now
      PairingMailer.user_2_starbucks_email(self).deliver_now
    end
  end

  def starbucks_gift_card
    claim_gift_card! 'Starbucks'
  end

  def process_event!(params)
    return unless self.class.statuses.include?(params[:event])
    status = [self.class.statuses[self.status], self.class.statuses[params[:event]]].max
    update! status: status

    user = users.find { |u| u.email == params[:recipient] }
    return unless user.present?
    user.update! geolocation: params[:geolocation], ip: params[:ip], info: params['client-info']
  end

  def users
    [user_1, user_2]
  end

  private

  def user_locations
    locations = users.map { |u| u.zip.present? ? (ZipCodes.identify(u.zip) || {}) : {} }
    locations.each do |h|
      h[:time_zone_nice] = ActiveSupport::TimeZone::MAPPING.find {|_, v| v == h[:time_zone] }.first if h[:time_zone].present?
    end
  end

  def claim_gift_card!(store)
    card = gift_cards.where(store: store).first
    return card if card.present?
    card = GiftCard.where(store: store, pairing_id: nil).first
    card.update! pairing: self
    card
  end
end
