class Users::SessionsController < ApplicationController

  def new
  end 

  def destroy
    if user_signed_in? 
      sign_out(current_user)
    end 
    redirect_to root_path
  end 

end 

