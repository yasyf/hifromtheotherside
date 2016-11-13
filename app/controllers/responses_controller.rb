class ResponsesController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if current_user.present? && current_user.supported.blank?
      redirect_to action: :new
    end
  end

  def new
    @user = current_user
  end

  def create
    current_user.update! user_params
    flash.notice = "Preferences saved!"
    redirect_to action: :index
  end

  private

  def user_params
    params.require(:user).permit(:zip, :supported, :desired, :background)
  end
end
