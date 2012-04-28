class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_administrator!, :only => [:signup_info_edit, :signup_info_update]
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

  def signup_info_edit
    @user = @current_admin
  end

  def signup_info_update
    @user = @current_admin

    params[:user][:signup_step] = 2
    respond_to do |format|
      if @user.update_attributes(params[:user])
        if @user.account.nil?
          account = @user.create_account(:name => @current_admin.nickname)
        end
        if @user.account and (@app = @user.account.apps.create(:name => params[:app_name])) and @app.valid?
          flash[:notice] = 'Successfully to create app'
          format.html { redirect_to app_path(@app, :setup => true) }
        else
          flash.now[:notice] = 'Failed to complete profile'
          format.html { render action: "signup_info_edit" }
        end
      else
        flash.now[:notice] = 'Failed to complete profile'
        format.html { render action: "signup_info_edit" }
      end
    end
  end

  protected

  def check_administrator!
    if not current_user.administrator?
      redirect_to edit_user_path(current_user)
      return
    else
      @current_admin = current_user.becomes(current_user.type.constantize)
    end
  end
end
