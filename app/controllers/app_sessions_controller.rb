class AppSessionsController < ApplicationController
  # GET /app_sessions
  # GET /app_sessions.json
  def index
    @app_sessions = AppSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @app_sessions }
    end
  end

  # GET /app_sessions/1
  # GET /app_sessions/1.json
  def show
    @app_session = AppSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_session }
    end
  end

  # POST /app_sessions.xml
  def create
    if params[:app_session].nil?
      render xml: "Missing app_session key", status: :bad_request
      return
    end

    as_params = params[:app_session]
    @app = App.find_by_token(as_params.delete :app_token)
    if @app.nil?
      render xml: "Missing App Token", status: :bad_request
      return
    end
    as_params.merge! app_id: @app.id
    @app_session = AppSession.new as_params

    respond_to do |format|
      if @app_session.save
        format.xml
      else
        format.xml { render xml: @app_session.errors, status: :bad_request }
      end
    end
  end

  # PUT /app_sessions/1.xml
  def update
    @app_session = AppSession.find(params[:id])

    respond_to do |format|
      if @app_session.update_attributes(params[:app_session])
        format.xml { head :no_content }
      else
        format.xml { render xml: @app_session.errors, status: :unprocessable_entity }
      end
    end
  end

end
