class AdminController < ApplicationController
  USER_LIMIT = 50

  def index
    unless ENV['ADMINS'].split(',').include? current_user&.uid
      render status: :forbidden, nothing: true
      return
    end

    scope = User.order(:created_at).completed
    if paired?
      scope = scope.paired
      @title = 'Paired Users'
    else
      scope = scope.unpaired
      @title = 'Unpaired Users'
    end
    @pages = scope.count / USER_LIMIT
    @users = scope.limit(USER_LIMIT).offset(page * USER_LIMIT)
  end

  def pair
    user = User.find(params[:id])
    Pairing.pair!(user, user.possible_pairing)
    render js: '$("[data-dismiss=modal]").trigger({ type: "click" }); location.reload();'
  end

  private

  def page
    @page ||= params[:page].present? ? params[:page].to_i : 0
  end

  def paired?
    @paired ||= params[:paired]&.downcase == 'true'
  end
end
