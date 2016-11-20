class AdminController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def index
    if not current_user.present?
      render status: :forbidden
      return
    end

    admin_uids = [
      "10157774150465553" # Josh G
    ]

    if not admin_uids.include? current_user.uid
      render status: :forbidden
      return
    end

    @users = User.order(:id).take(100000)

    render layout: "application"
  end
end
