class AccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_admin, :only => [:edit, :update, :show, :add_credit, :view_credit]

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
        @account.add_credits Account::FreeCredits

        flash[:notice] = I18n.t("account.create.success")
        redirect_to apps_path
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

  def view_credit
    if @admin.blank?
      respond_to do |format|
        format.html { redirect_to root_path }
      end
      return
    end
    @account = @admin.account

    respond_to do |format|
      format.html { render :layout => 'iframe' }
    end
  end

  def add_credit
    if @admin.blank?
      redirect_to root_path
      return
    end

    @account = @admin.account

    # "add-credit-quantity-one"=>"0", "add-credit-quantity-few"=>"0", "add-credit-quantity-volume"=>"2", "stripeToken"=>"tok_RlxYOlf8bM8t9E", "total_price"=>"200", "total_credits"=>"100", "account_id"=>"1"}
    # credit params check
    if params[:total_price].blank? or params[:total_credits].blank? or not params[:total_credits].to_i
      result = { 'result' => 'fail',
                 'reason' => 'Parameter missing' }
      respond_to do |format|
        format.json { render :json => result }
      end
      return
    end

    if params[:total_price].to_i == 0 or params[:total_credits].to_i == 0
      result = { 'result' => 'fail',
                 'reason' => 'You have not purchased anything' }
      respond_to do |format|
        format.json { render :json => result }
      end
      return
    end

    # validate total price and credits
    expected_price = 0
    expected_credits = 0
    PAYMENT_CONFIG['plans'].each do |plan|
      quantity = params["add-credit-quantity-#{plan['name']}"].to_i;
      expected_price += quantity * plan['price']
      expected_credits += quantity * plan['credit']
    end
    if expected_price != params[:total_price].to_i or expected_credits != params[:total_credits].to_i
      result = { 'result' => 'fail',
                 'reason' => 'Invalid request' }  # error msg does not specify details regarding check logic
      respond_to do |format|
        format.json { render :json => result }
      end
      return
    end

    # payment params check
    if not params[:stripeToken]
      result = { 'result' => 'fail',
                 'reason' => 'Invalid payment information' }
      respond_to do |format|
        format.json { render :json => result }
      end
      return
    end

    # add credit
    # payment
    Stripe.api_key = ENV['STRIP_SECRET']
    token = params[:stripeToken]

    charge = Stripe::Charge.create(
      :amount => params[:total_price].to_i,
      :currency => "usd",
      :card => token,
      :description => "credit purchase from account #{@account.id} - #{@account.name} - #{@account.administrator.email}"
    )

    respond_to do |format|
      if charge.paid
        remaining_credits = @account.remaining_credits
        new_credits = @account.add_credits params[:total_credits].to_i
        if new_credits == (remaining_credits + params[:total_credits].to_i)
          format.json { render :json => { "result" => "success", "remaining_credits" => @account.remaining_credits } }
        else
          format.json { render :json => { "result" => "fail", "reason" => "Failed to add credit" } }
        end
      else
        format.json { render :json => { "result" => "fail", "reason" => "Failed to charge" } }
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
