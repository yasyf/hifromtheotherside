class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    begin
      @user = User.from_omniauth(request.env["omniauth.auth"])
    rescue ActiveRecord::RecordInvalid
      flash.alert = "Your email is required to continue!"
      redirect_to root_path
    else
      sign_in @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    end

    redirect_to new_response_path
  end

  def failure
    redirect_to root_path
  end
end
