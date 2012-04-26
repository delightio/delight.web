class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_user_registration

  def after_sign_in_path_for(resource)
    apps_path
  end

  protected

  # require user to complete profile before proceed
  def check_user_registration
    if user_signed_in? and not current_user.done_registering?
      if current_user.administrator?
        redirect_to user_signup_info_edit_path(current_user)
      else
        redirect_to edit_user_path(current_user)
      end
      return
    end
  end

end
