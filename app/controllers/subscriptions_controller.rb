class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

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
      render json: @subscription
    else
      render json: @subscription.errors, status: :bad_request
    end
  end

  def show
    @subscription = Subscription.find params[:id]
    render json: @subscription
  end
end