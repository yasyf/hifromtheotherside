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

    # Searches all string fields; presumably won't match ZIP.
    scope = scope.fuzzy_search(params[:name_email]) if params[:name_email].present?
    # The first 3 digits of a ZIP code indicate a postal delivery region.
    scope = scope.zip_starts_with(params[:zip][0..2]) if params[:zip].present?
    scope = scope.where(supported: params[:supported].to_i) if params[:supported].present?

    @pages = scope.count('*') / USER_LIMIT
    @users = scope.order(:created_at).limit(USER_LIMIT).offset(page * USER_LIMIT)
  end

  def pair
    user = User.find(params[:id])
    pairing = Pairing.pair!(user, user.possible_pairing)
    flash[:notice] = "Emails to #{pairing.user_1.first_name} and #{pairing.user_2.first_name} sent!"
    render js: '$("[data-dismiss=modal]").trigger({ type: "click" }); location.reload();'
  end

  def destroy
    user = User.find(params[:id])
    if user.pairings.present?
      flash[:alert] = "Cannot remove user with active pairings!"
    else
      user.destroy!
      flash[:notice] = "#{user.name} has been removed!"
    end
    render js: 'location.reload();'
  end

  private

  def page
    @page ||= params[:page].present? ? params[:page].to_i : 0
  end

  def paired?
    @paired ||= params[:paired]&.downcase == 'true'
  end
end
