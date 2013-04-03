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

  def subscribe
    stripe_token = params[:stripe_token]
    plan = Plan.find params[:subscription][:plan_id]
    @subscription = Subscription.find params[:subscription_id]
    if (@subscription.subscribe plan, stripe_token)
      notice = "Updated current subscription to #{plan.name} plan."
      respond_to do |format|
        format.html { redirect_to apps_path, :flash => { :notice => notice } }
        format.json { render :json => { "result" => "success", "subscription" => @subscription, "message" => notice }  }
      end
    else
      render :json => {
        "result" => "fail",
        "message" => "Subscription[#{@subscription.id}] did not get updated.",
        "subscription" => @subscription 
      }, status => :bad_request
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