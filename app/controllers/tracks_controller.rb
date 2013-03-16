class TracksController < ApplicationController
  def create
    if params[model_param_key].nil?
      render xml: "Missing #{model_param_key} key", status: :bad_request
      return
    end

    token = get_token
    if token.nil?
      render xml: "Missing HTTP_X_NB_AUTHTOKEN HTTP header", status: :bad_request
      return
    end

    if params[model_param_key][:app_session_id].nil?
      render xml: "Missing #{model_param_key}.app_session_id key", status: :bad_request
      return
    end

    @app_session = AppSession.find(params[model_param_key][:app_session_id])
    if token != @app_session.app.token
      render xml: "Token mismatch", status: :bad_request
      return
    end

    @track = model_class.new params[model_param_key]

    respond_to do |format|
      if @track.save
        format.xml # TODO: should use custom show.xml. We also don't return the right status code
        #format.xml { render :xml => @track, :status => 201 }
      else
        format.xml { render xml: @track.errors, status: :bad_request }
      end
    end
  end

  def show
    unless request.format.json?
      authenticate_user!
    else
      authenticated = authenticate_by_token
      return unless authenticated
    end

    @track = model_class.find(params[:id]) # throws exception if not found
    app = @track.app_session.app
    if app.administered_by?(current_user) or app.viewable_by?(current_user)
      respond_to do |format|
        format.html { render :layout => 'empty' }
      end
    else
      respond_to do |format|
        format.json { render json: @track.to_json }
        format.html do
          flash[:type] = 'error'
          flash[:notice] = 'permission denied'
          redirect_to apps_path
        end
      end
    end
  end

  # TODO: Should put ApplicationController and use before_filter to trigger
  def authenticate_by_token
    token = get_token
    if token.nil?
      render json: "Missing HTTP_X_NB_AUTHTOKEN HTTP header", status: :bad_request
      return false
    end

    # We verify by two ways:
    # 1. if app session id is present, does the app token match the associated app?
    # 2. does the current track belongs to the app session which the app token points to?
    true_token = Track.find(params[:id]).app_session.app.token

    if token != true_token
      render json: "Token mismatch", status: :bad_request
      return false
    end

    true
  end

  def sample
    respond_to do |format|
      format.html { render :layout => 'empty' }
    end
  end

  def model_class
    Track
  end

  def model_param_key
    @model_param_key || model_class.to_s.tableize.singularize.to_sym
  end

  protected

  def get_token
    request.env['HTTP_X_NB_AUTHTOKEN']
  end
end
