class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_administrator!, :only => [:signup_info_edit, :signup_info_update]
  skip_before_filter :check_user_registration

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    params[:user][:signup_step] = 2
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
    if @user.account.nil?
      @user.build_account
    end
    if @user.account.apps.blank?
      @user.account.apps.new
    else
      respond_to do |format|
        format.html { redirect_to(apps_path) }
      end
    end
  end

  def signup_info_update
    @user = @current_admin
    if @user.account and not @user.account.apps.blank?
      respond_to do |format|
        format.html { redirect_to(apps_path) }
      end
      return
    end

    params[:user][:signup_step] = 2
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Successfully to create app'
        session[:app_first] = true
        format.html { redirect_to app_path(@user.account.apps.first) }
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
