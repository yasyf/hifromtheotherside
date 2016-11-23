class Pairing < ApplicationRecord
  belongs_to :user_1, class_name: "User"
  belongs_to :user_2, class_name: "User"

  validates :user_2, uniqueness: { scope: :user_1 }

  enum status: [:unknown, :bounced, :delivered, :opened, :clicked]

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
    PairingMailer.paired_email(self).deliver_now
  end

  def process_event!(params)
    return unless self.class.statuses.include?(params[:event])
    status = [self.class.statuses[self.status], self.class.statuses[params[:event]]].max
    update! status: status, geolocation: params[:geolocation], ip: params[:ip], info: params['client-info']
  end
end
