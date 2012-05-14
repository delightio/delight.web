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
        #format.xml # TODO: should use custom show.xml. We also don't return the right status code
        format.xml # TODO: should use custom show.xml. We also don't return the right status code
        #format.xml { render :xml => @track, :status => 201 }
      else
        format.xml { render xml: @track.errors, status: :bad_request }
      end
    end
  end

  def show
    authenticate_user!
    @track = model_class.find(params[:id]) # throws exception if not found
    app = @track.app_session.app
    if app.administered_by?(current_user) or app.viewable_by?(current_user)
      respond_to do |format|
        format.html { render :layout => 'empty' }
      end
    else
      respond_to do |format|
        format.html do
          flash[:type] = 'error'
          flash[:notice] = 'permission denied'
          redirect_to apps_path
        end
      end
    end
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
    :track
  end

  protected

  def get_token
    if ENV['USE_URL_PARAM_API_TOKEN'] == 'y'
      token = params[:token]
    else
      token = request.env['HTTP_X_NB_AUTHTOKEN']
    end
  end
end
