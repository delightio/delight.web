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

  # GET /app_sessions/new
  # GET /app_sessions/new.json
  def new
    @app_session = AppSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app_session }
    end
  end

  # GET /app_sessions/1/edit
  def edit
    @app_session = AppSession.find(params[:id])
  end

  # POST /app_sessions
  # POST /app_sessions.json
  def create
    @app_session = AppSession.new(params[:app_session])

    respond_to do |format|
      if @app_session.save
        format.html { redirect_to @app_session, notice: 'App session was successfully created.' }
        format.json { render json: @app_session, status: :created, location: @app_session }
      else
        format.html { render action: "new" }
        format.json { render json: @app_session.errors, status: :unprocessable_entity }
      end
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
