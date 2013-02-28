class TracksController < ApplicationController
  before_filter :authenticate!

  def authenticate!
    if request.format.html?
      authenticate_user!
    else
      authenticate_by_token!
    end
  end

  def create
    if params[model_param_key].nil?
      render xml: "Missing #{model_param_key} key", status: :bad_request
      return
    end

    if params[model_param_key][:app_session_id].nil?
      render xml: "Missing #{model_param_key}.app_session_id key", status: :bad_request
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

  def authenticate_by_token!
    token = get_token
    if token.nil?
      render xml: "Missing HTTP_X_NB_AUTHTOKEN HTTP header", status: :bad_request
      return
    end

    # We verify by two ways:
    # 1. if app session id is present, does the app token match the associated app?
    # 2. does the current track belongs to the app session which the app token points to?
    true_token = nil
    if params[model_param_key].nil? || params[model_param_key][:app_session_id].nil?
      if params[:id].nil?
        render xml: "Missing #{model_param_key}.app_session_id key", status: :bad_request
        return
      end
      track = model_class.find params[:id]
      true_token = track.app_session.app.token

    else
      app_session = AppSession.find(params[model_param_key][:app_session_id])
      true_token = app_session.app.token
    end

    if token != true_token
      render xml: "Token mismatch", status: :bad_request
      return
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
