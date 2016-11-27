class PairingMailer < ApplicationMailer
  default from: 'Hi From The Other Side <noreply@hifromtheotherside.com>', reply_to: 'Henry Tsai <henry@hifromtheotherside.com>'

  def paired_email(pairing)
    @user_1 = pairing.user_1
    @user_2 = pairing.user_2

    users = [@user_1, @user_2]
    @locations = users.map { |u| u.zip.present? ? (ZipCodes.identify(u.zip) || {}) : {} }
    @locations.each do |h|
      h[:time_zone_nice] = ActiveSupport::TimeZone::MAPPING.find {|_, v| v == h[:time_zone] }.first if h[:time_zone].present?
    end

    to = users.map { |u| "#{u.name} <#{u.email}>" }
    mail to: to, subject: 'Your "Hi From The Other Side" Match!'
  end
end
