class AdminController < ApplicationController
  USER_LIMIT = 50

  def index
    unless ENV['ADMINS'].split(',').include? current_user&.uid
      render status: :forbidden, nothing: true
      return
    end

    scope = User.completed
    if paired?
      scope = scope.paired
      @title = 'Paired Users'
    else
      scope = scope.unpaired
      @title = 'Unpaired Users'
    end
    @users = scope.order(:created_at).take(USER_LIMIT)
  end

  def pair
    user = User.find(params[:id])
    Pairing.pair!(user, user.possible_pairing)
    render js: '$("[data-dismiss=modal]").trigger({ type: "click" }); location.reload();'
  end

  private

  def paired?
    @paired ||= params[:paired]&.downcase == 'true'
  end
end
