class UsersController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :check_user_registration

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Successfully updated profile'
        format.html { redirect_to apps_path }
      else
        flash.now[:notice] = 'Failed to updated profile'
        format.html { render action: "edit" }
      end
    end
  end
end
