class SchedulersController < ApplicationController
  before_filter :authenticate_user!

  def update
    @scheduler = Scheduler.find params[:id]
    if @scheduler.update_attributes params[:scheduler]
      render json: @scheduler
    else
      render json: @scheduler.errors, status: :bad_request
    end
  end

  def show
    @scheduler = Scheduler.find params[:id]
    render json: @scheduler
  end
end
