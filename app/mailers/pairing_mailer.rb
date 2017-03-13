class PairingMailer < ApplicationMailer
  default from: 'Hi From The Other Side <noreply@hifromtheotherside.com>', reply_to: 'Henry Tsai <henry@hifromtheotherside.com>'

  def paired_email(pairing, user_locations)
    @user_1 = pairing.user_1
    @user_2 = pairing.user_2
    @locations = user_locations
    @same_city = @locations[0][:city] == @locations[1][:city]
    @nearest_starbucks = Location.new(@user_1.zip).nearest_starbucks if @same_city

    to = pairing.users.map { |u| "#{u.name} <#{u.email}>" }
    mail to: to, subject: 'Your "Hi From The Other Side" Match!'
  end

 def user_1_starbucks_email(pairing)
    @user = pairing.user_1
    @other = pairing.user_2
    @url = pairing.starbucks_gift_card.url

    to = "#{@user.name} <#{@user.email}>"
    mail to: to, subject: 'Redeeming your Starbucks eGift card'
  end

  def user_2_starbucks_email(pairing)
    @user = pairing.user_2
    @other = pairing.user_1
    @challenge = pairing.starbucks_gift_card.challenge

    to = "#{@user.name} <#{@user.email}>"
    mail to: to, subject: 'Redeeming your Starbucks eGift card'
  end
end
