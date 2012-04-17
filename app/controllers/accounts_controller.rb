class AccountsController < ApplicationController
  before_filter :authenticate_user! 
  before_filter :get_admin, :only => [:edit, :update, :show] 

  def create
    # check if user is admin and have account already 
    if current_user.type == 'Administrator' 
      admin = current_user.becomes(current_user.type.constantize) 
      if not admin.account.blank? 
        redirect_to account_path(admin.account) 
        return 
      end 
    end 
    
    current_user.type = 'Administrator'
    current_user.save 

    if params[:account].blank? 
      flash.now[:type] = "error" 
      flash.now[:notice] = I18n.t("account.create.fail")
      render :action => :new 
      return
    end 
    @account = Account.create({:administrator_id => current_user.id}.merge(params[:account]))

    #respond_to do |format| 
      if current_user.valid? and @account
        flash[:notice] = I18n.t("account.create.success")
        redirect_to account_path(:id => @account.id)
      else 
        flash.now[:type] = "error" 
        flash.now[:notice] = I18n.t("account.create.fail")
        render :action => :new 
      end 
    #end 
  end

  def new
    @account = Account.new 
  end

  def edit
    if @admin.blank? 
      redirect_to root_path 
      return 
    end 

    @account = @admin.account

    respond_to do |format| 
      if @account.blank? or not @account.id.to_s == params[:id]
        format.html { redirect_to root_path }
      else 
        format.html 
      end 
    end 

  end

  def show
    if @admin.blank? 
      redirect_to root_path
      return 
    end 

    @account = @admin.account 
    
    respond_to do |format| 
      if @account.blank? or not @account.id.to_s == params[:id] 
        format.html { redirect_to root_path }
      else 
        format.html
      end 
    end 
  end

  def update
    if @admin.blank? 
      redirect_to root_path 
      return 
    end 

    @account = @admin.account 

    respond_to do |format| 
      if @account.blank? or not @account.id.to_s == params[:id] or params[:account].blank? 
        redirect_to root_path
        return 
      end 

      if @account.update_attributes(params[:account]) 
        flash[:notice] = I18n.t("account.update.success") 
        format.html { redirect_to(account_path(@account)) } 
      else 
        flash.now[:type] = 'error' 
        flash.now[:notice] = I18n.t("account.update.fail")
        format.html { render :action => :edit } 
      end 
    end 

  end

#  def destroy
#  end

  protected 

  def get_admin 
    if current_user.type == 'Administrator' 
      @admin = current_user.becomes('Administrator'.constantize)
    else 
      @admin = nil 
    end 
    @admin
  end 
 
end
