class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @current_plan = current_user.account.subscription.plan
  end

  def create
    @subscription = Subscription.new params[:subscription]
    if @subscription.save
      render json: @subscription
    else
      render json: @subscription.errors, status: :bad_request
    end
  end

  def update
    @subscription = Subscription.find params[:id]
    if @subscription.update_attributes params[:subscription]
      notice = "Updated current subscription."
      if params[:subscription].has_key? :plan_id
        plan = Plan.find params[:subscription][:plan_id]
        notice = "Updated current subscription to #{plan.name} plan."
      end
      respond_to do |format|
        format.html { redirect_to apps_path, :flash => { :notice => notice } }
        format.json { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { redirect_to apps_path, :flash => { :error => @subscription.errors } }
        format.json { render :json => @subscription.errors, :status => :bad_request}
      end
    end
  end

  def show
    if params[:id].to_i != current_user.account.subscription.id
        respond_to do |format|
          format.html do
            flash[:type] = 'error'
            flash[:notice] = 'You do not have permission to change subscription'
            redirect_to apps_path
          end
        end
        return
    end

    @subscription = Subscription.find params[:id]
    respond_to do |format|
      format.html # show.html.erb
    end
  end
end