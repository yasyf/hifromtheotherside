class AdminController < ApplicationController
  before_action :authenticate_user!

  USER_LIMIT = 100000

  def index
    unless ENV['ADMINS'].split(',').include? current_user&.uid
      render status: :forbidden
      return
    end

    @users = User.order(:id).take(USER_LIMIT)
  end
end
