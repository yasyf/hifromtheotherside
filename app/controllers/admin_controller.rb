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
    scope = scope.fuzzy_search(params[:q]) if params[:q].present?
    @pages = scope.count('*') / USER_LIMIT
    @users = scope.order(:created_at).limit(USER_LIMIT).offset(page * USER_LIMIT)
  end

  def pair
    user = User.find(params[:id])
    pairing = Pairing.pair!(user, user.possible_pairing)
    flash[:notice] = "Emails to #{pairing.user_1.first_name} and #{pairing.user_2.first_name} sent!"
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
