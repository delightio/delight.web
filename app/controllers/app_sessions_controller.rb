class AppSessionsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do
    flash[:type] = 'error'
    flash[:notice] = 'Invalid operation'
    redirect_to apps_path
    return
  end

  # TODO: remove
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
  def show
    authenticate_user!

    @app_session = nil
    if current_user.administrator?
      @app_session ||= AppSession.administered_by(current_user).find(params[:id])
    end

    @app_session ||= AppSession.viewable_by(current_user).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
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
