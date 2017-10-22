class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate!

  def authenticate!
    if Rails.env.development?
      sign_in User.first unless current_user.present?
    end
    authenticate_user!
  end

  def letsencrypt
      render text: "umjwn4rfyoL0km2KHOfaYmN2M_jHXlCpOsLntKDMKgw.AHWiAAL-FVqxtSipUIJmj6LTEy4QEzaAsd0iUXPLu7U"
  end
end
