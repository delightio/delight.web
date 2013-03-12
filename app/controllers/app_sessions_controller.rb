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
    if @app_session.nil?
      flash[:type] = 'error'
      flash[:notice] = 'Invalid operation'
      respond_to do |format|
        format.html { redirect_to apps_path }
        format.json { render :json => { 'result' => 'fail', 'reason' => 'record not found' } }
      end

      return
    end
    @track = @app_session.presentation_track
    @front_track = @app_session.front_track
    @is_admin = @app_session.app.account.administrator == current_user

    respond_to do |format|
      if @app_session.instance_of?(UsabilityAppSession)
        format.html { render :template => 'app_sessions/show_two', :layout => 'iframe_black' } # show.html.erb
      else
        format.html { render :template => 'app_sessions/show', :layout => 'iframe_black' } # show.html.erb
      end
    end
  end

  # PUT /app_sessions/1/favorite
  def favorite
    authenticate_user!
    @app_session = get_app_session(params[model_param_key_id])
    if @app_session.nil?
      flash[:type] = 'error'
      flash[:notice] = 'Invalid operation'
      respond_to do |format|
        format.html { redirect_to apps_path }
        format.json { render :json => { 'result' => 'fail', 'reason' => 'record not found' } }
      end
      return
    end

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
    @app_session = get_app_session(params[model_param_key_id])
    if @app_session.nil?
      flash[:type] = 'error'
      flash[:notice] = 'Invalid operation'
      respond_to do |format|
        format.html { redirect_to apps_path }
        format.json { render :json => { 'result' => 'fail', 'reason' => 'record not found' } }
      end
      return
    end

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
    if params[model_param_key].nil?
      render xml: "Missing app_session key", status: :bad_request
      return
    end

    token = get_token
    if token.nil?
      render xml: "Missing HTTP_X_NB_AUTHTOKEN HTTP header", status: :bad_request
      return
    end

    @model_param = model_param_key
    as_params = params[model_param_key]
    @app = App.find_by_token(token)
    if @app.nil?
      render xml: "Missing App Token. Get yours on http://delight.io", status: :bad_request
      return
    end
    as_params.merge! app_id: @app.id
    as_params.delete :app_token # since it's not a proper attribute on AppSession

    # LH 110
    if as_params[:delight_version].to_i < 2
      as_params[:app_locale] = as_params.delete :locale
    end

    # LH 206
    if as_params[:device_os_version].to_f < 4.1
      if @app.settings['ios_version_notification'].nil?
        SystemMailer.ios_version_notification(@app, as_params[:device_os_version]).deliver
        @app.settings['ios_version_notification'] = "sent"
      end
      render xml: "Minimum iOS version need to be 4.1. Please upgrade the framework.", status: :bad_request
      return
    end

    # GH #18 handle extra properties and metrics before our iOS clients are updated.
    as_params.delete :properties
    as_params.delete :metrics

    @app_session = model_class.new as_params

    respond_to do |format|
      if @app_session.save
        puts "App[#{@app.id}, #{@app.name}] AppSession[#{@app_session.id}] created. Recording? #{@app_session.recording?}"
        format.xml
      else
        format.xml { render xml: @app_session.errors, status: :bad_request }
      end
    end
  end

  # PUT /app_sessions/1.xml
  def update
    token = get_token
    if token.nil?
      render xml: "Missing HTTP_X_NB_AUTHTOKEN HTTP header", status: :bad_request
      return
    end

    @app_session = model_class.find(params[:id])
    if @app_session.app.token != token
      render xml: "Token mismatch", status: :bad_request
      return
    end
    respond_to do |format|
      properties = params[model_param_key].delete :properties
      metrics = params[model_param_key].delete :metrics

      if @app_session.update_attributes(params[model_param_key]) &&
         @app_session.update_properties(properties) &&
         @app_session.update_metrics(metrics)
        format.xml { head :no_content }
      else
        format.xml { render xml: @app_session.errors, status: :unprocessable_entity }
      end
    end
  end

  def model_class
    AppSession
  end

  def model_param_key
    @model_param_key || model_class.to_s.tableize.singularize.to_sym
  end

  def model_param_key_id
    @model_param_key_id ||= "#{model_param_key}_id".to_sym
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
      app_session ||= model_class.administered_by(current_user).find_by_id(session_id)
    end
    app_session ||= model_class.viewable_by(current_user).find_by_id(session_id)
  end

  def get_token
    request.env['HTTP_X_NB_AUTHTOKEN']
  end

end
