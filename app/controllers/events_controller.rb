class EventsController < ApplicationController
  before_filter :find_app
  def index
    @events = @app.events.search(params[:query])
    render :json => @events.to_json
  end

private
  def find_app
    @app = App.find(params[:app_id])
  end
end