class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate!
  before_action :validate!

  def hook
    pairing&.process_event!(params.slice(:geolocation, :event, :ip, 'client-info'))
  end

  private

  def pairing
    @pairing ||= Pairing.from_event(params.slice(:message, :recipient))
  end

  def validate!
    digest = OpenSSL::Digest::SHA256.new
    data = params.slice(:timestamp, :token).values.join
    expected = OpenSSL::HMAC.hexdigest(digest, ENV['MAILGUN_API_KEY'], data)
    head(:forbidden) unless signature == expected
  end
end
