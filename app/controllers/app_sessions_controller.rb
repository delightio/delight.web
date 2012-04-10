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

  # # GET /app_sessions/new
  # # GET /app_sessions/new.json
  # def new
  #   @app_session = AppSession.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @app_session }
  #   end
  # end

  # # GET /app_sessions/1/edit
  # def edit
  #   @app_session = AppSession.find(params[:id])
  # end

  # POST /app_sessions
  # POST /app_sessions.json
  def create
    @app = App.find_by_token params[:app_token]
    if @app.nil?
      render json: "Missing App Token", status: :bad_request
      return
    end

    required = { app_id: @app.id,
                 app_version: params[:app_version],
                 locale: params[:locale],
                 delight_version: params[:delight_version] }
    render json: required, status: :bad_request if required.has_value? nil
    options= required.merge app_user_id: params[:app_user_id]
    @app_session = AppSession.new required

    if @app_session.save
      render json: @app_session, status: :created
    else
      render json: @app_session.errors, status: :bad_request
    end
  end

  # PUT /app_sessions/1
  # PUT /app_sessions/1.json
  def update
    @app_session = AppSession.find(params[:id])

    respond_to do |format|
      if @app_session.update_attributes(params[:app_session])
        format.html { redirect_to @app_session, notice: 'App session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_sessions/1
  # DELETE /app_sessions/1.json
  def destroy
    @app_session = AppSession.find(params[:id])
    @app_session.destroy

    respond_to do |format|
      format.html { redirect_to app_sessions_url }
      format.json { head :no_content }
    end
  end
end
