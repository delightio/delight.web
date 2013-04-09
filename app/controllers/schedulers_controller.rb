class SchedulersController < ApplicationController
  before_filter :authenticate_user!

  def update
    @scheduler = Scheduler.find params[:id]
    if @scheduler.update_attributes params[:scheduler]
      render json: { :result => "success", :scheduler => @scheduler, :message => (@scheduler.recording ? "recording" : "idle") }
    else
      # error object can not return the scheduler object as the message is much more important
      render json: { :result => "fail", :message => @scheduler.errors } , status: :bad_request
    end
  end

  def show
    @scheduler = Scheduler.find params[:id]
    render json: @scheduler
  end
end
