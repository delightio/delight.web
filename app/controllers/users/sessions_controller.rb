class Users::SessionsController < ApplicationController
  skip_before_filter :check_user_registration

  def new
  end

  def destroy
    if user_signed_in?
      sign_out(current_user)
    end
    redirect_to root_path
  end

end

