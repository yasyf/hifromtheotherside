class AdminController < ApplicationController
  USER_LIMIT = 50

  def index
    unless ENV['ADMINS'].split(',').include? current_user&.uid
      render status: :forbidden, nothing: true
      return
    end

    @users = User.completed.unpaired.order(:created_at).take(USER_LIMIT)
  end

  def pair
    user = User.find(params[:id])
    Pairing.pair!(user, user.possible_pairing)
    render js: '$("[data-dismiss=modal]").trigger({ type: "click" });'
  end
end
