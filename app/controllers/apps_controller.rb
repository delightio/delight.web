class AppsController < ApplicationController
  before_filter :show_credit?, :only => [:index]
  before_filter :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    respond_to do |format|
      format.html do
        flash[:type] = 'error'
        flash[:notice] = 'Invalid operation'
        redirect_to :action => :index
      end
      format.json do
        render :json => { 'result' => 'fail', 'reason' => 'record not found' }
      end
    end
    return
  end

  # GET /apps
  def index
    @show_credit = params[:credit] || session[:credit]
    session[:credit] = nil

    if current_user.administrator?
      @admin_apps = App.administered_by(current_user).all
    else
      @admin_apps = nil
    end

    if @admin_apps.nil?
      @viewer_apps = App.viewable_by(current_user)
    else
      @viewer_apps = App.viewable_by(current_user).where("apps.id not in (?)", @admin_apps.map(&:id))
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /apps/1
  # GET /apps/1.js
  def show
    @app = nil

    #@setup = params[:setup]
    @setup = session[:app_first]
    if @setup
      session[:app_first] = nil
    end
    @app_session_id = params[:app_session_id]
    @app = App.find params[:id]
    @app = nil unless @app.viewable_by? current_user
    if @app.nil?
      respond_to do |format|
        format.html do
          flash[:type] = 'error'
          flash[:notice] = 'Invalid operation'
          redirect_to :action => :index
        end
        format.json do
          render :json => { 'result' => 'fail', 'reason' => 'record not found' }
        end
      end
      return
    end

    @last_viewed_at = @app.last_viewed_at_by_user(current_user)
    @app.log_view(current_user)

    # Filter
    @recorded_sessions = @app.app_sessions.recorded
    if params[:favorited]
      @recorded_sessions = @recorded_sessions.favorited
    elsif params[:funnel]
      funnel = Funnel.find(params[:funnel])
      @recorded_sessions = @recorded_sessions.by_funnel(funnel)
    end
    @recorded_sessions = @recorded_sessions.latest.page(params[:page]).per(12)

    respond_to do |format|
      format.html do
        render # show.html.erb
      end
      format.js # show.html.js
      format.json { render :json => { 'scheduled_recordings' => @app.scheduled_recordings } }
    end
  end

  # GET /apps/new
  def new
    if not current_user.administrator?
      redirect_to :action => :index
      return
    end

    @app = current_user.account.apps.build

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /apps/1/edit
  def edit
    @app = App.administered_by(current_user).find(params[:id])
  end

  # POST /apps
  def create
    if not current_user.administrator?
      redirect_to :action => :index
      return
    end

    @app = current_user.account.apps.build(params[:app])

    respond_to do |format|
      if @app.save
        #@app.schedule_recordings Account::FreeCredits

        flash[:notice] = 'App was successfully created.'
        session[:app_first] = true
        format.html { redirect_to app_path(@app) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /apps/1
  def update
    @app = App.administered_by(current_user).readonly(false).find(params[:id])

    respond_to do |format|
      if @app.update_attributes(params[:app])
        flash[:notice] = 'App was successfully updated.'
        format.html { redirect_to :action => :index }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /apps/1
  def destroy
    @app = App.administered_by(current_user).find(params[:id])
    @app.destroy

    respond_to do |format|
      format.html { redirect_to apps_url }
    end
  end

  def update_recording
    # @app = App.administered_by(current_user).find(params[:app_id])
    @app = App.find params[:app_id]
    raise ActiveRecord::RecordNotFound unless @app.administered_by?(current_user)

    case params[:state]
    when 'pause'
      @app.pause_recording
      result = { 'result' => 'success' }
    when 'resume'
      @app.resume_recording
      result = { 'result' => 'success' }
    else
      result = { 'result' => 'fail', 'reason' => 'invalid state' }
    end

    respond_to do |format|
      format.json { render :json => result }
    end
  end

  def setup
    @app = App.administered_by(current_user).find(params[:app_id])
    respond_to do |format|
      format.html { render :layout => 'iframe' }
    end
  end

  def schedule_recording_edit
    # @app = App.administered_by(current_user).find(params[:app_id])
    @app = App.find params[:app_id]
    raise ActiveRecord::RecordNotFound unless @app.administered_by?(current_user)
    respond_to do |format|
      format.html { render :layout => 'iframe' }
    end
  end

  def schedule_recording_update
    # @app = App.administered_by(current_user).find(params[:app_id])
    @app = App.find params[:app_id]
    raise ActiveRecord::RecordNotFound unless @app.administered_by?(current_user)
    @account = @app.account
    @schedule_recording = params[:schedule_recording].to_i
    respond_to do |format|
      if @schedule_recording.to_i > 0 &&
         @account.enough_credits?(@schedule_recording)
        @app.schedule_recordings @schedule_recording
        flash[:notice] = 'Successfully scheduled recordings'
        format.html { redirect_to :action => :schedule_recording_edit }
      else
        flash.now[:type] = 'error'
        flash.now[:notice] = "Failed scheduling #{@schedule_recording} recordings"
        unless @account.enough_credits?(@schedule_recording)
           flash.now[:notice] = "Sorry. Not enough credits to schedule #{@schedule_recording} sessions"
         end
        format.html { render action: "schedule_recording_edit", :layout => 'iframe' }
      end
    end
  end

  def show_credit?
    if params[:credit]
      session[:credit] = params[:credit]
    end
  end

  def upload_on_wifi_only
    if params[:state].nil?
      respond_to do |format|
        format.json { render :json => { 'result' => 'fail', 'reason' => 'param state is missing' } }
      end
      return
    end

    # validate app id
    # @app = App.administered_by(current_user).find(params[:app_id])
    @app = App.find params[:app_id]
    if !@app.administered_by? current_user
      respond_to do |format|
        format.json { render :json => { 'result' => 'fail', 'reason' => 'access denied' } }
      end
      return
    end

    state = params[:state]
    if state.to_i != 0 # convert to 'true' or 'false'
      state = 'true'
    else
      state = 'false'
    end

    ret = @app.set_uploading_on_wifi_only state

    respond_to do |format|
      if ret
        format.json { render :json => { 'result' => 'success' } }
      else
        format.json { render :json => { 'result' => 'fail', 'reason' => 'fail to update state' } }
      end
    end
  end

end
