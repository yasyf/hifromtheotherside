class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate!

  def authenticate!
    if Rails.env.development?
      sign_in User.first unless current_user.present?
    end
    authenticate_user!
  end
end
