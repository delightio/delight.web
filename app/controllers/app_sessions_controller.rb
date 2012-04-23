class AppSessionsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:type] = 'error'
    flash[:notice] = 'Invalid operation'
    respond_to do |format|
      format.html { redirect_to apps_path }
      format.json { render :json => { 'result' => 'fail', 'reason' => 'record not found' } }
    end
  end

  # GET /app_sessions/1
  def show
    authenticate_user!
    @app_session = get_app_session

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # PUT /app_sessions/1/favorite
  def favorite
    authenticate_user!
    @app_session = get_app_session(params[:app_session_id])

    respond_to do |format|
      format.json do
        if @app_session
          current_user.favorite_app_sessions << @app_session
          render :json => { 'result' => 'success' }
        else
          render :json => { 'result' => 'fail', 'reason' => 'permission denied' }
        end
      end
    end
  end

  # PUT /app_sessions/1/unfavorite
  def unfavorite
    authenticate_user!
    @app_session = get_app_session(params[:app_session_id])

    respond_to do |format|
      format.json do
        if @app_session
          current_user.favorite_app_sessions.delete(@app_session)
          render :json => { 'result' => 'success' }
        else
          render :json => { 'result' => 'fail', 'reason' => 'permission denied' }
        end
      end
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

  protected

  # get app session where user has permission
  # return the app_session, nil if not available
  def get_app_session(session_id = nil)
    if session_id.nil?
      session_id = params[:id]
    end

    app_session = nil
    if current_user.administrator?
      app_session ||= AppSession.administered_by(current_user).find(session_id)
    end
    app_session ||= AppSession.viewable_by(current_user).find(session_id)
  end

end
