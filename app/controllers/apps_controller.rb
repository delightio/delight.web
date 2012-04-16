class AppsController < ApplicationController
  # GET /app_sessions
  # GET /app_sessions.json
  def index
    @apps = App.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end
end
