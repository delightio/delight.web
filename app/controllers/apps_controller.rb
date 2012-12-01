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

    @recorded_sessions = @app.app_sessions.recorded
    @versions = @recorded_sessions.select('app_sessions.app_version, count(1)').group(:'app_sessions.app_version')
    versions = params[:versions] || @versions.collect { |v| v.app_version }

    @builds = @recorded_sessions.select('app_sessions.app_build, count(1)').group(:'app_sessions.app_build')
    builds = params[:builds] || @builds.collect { |b| b.app_build }

    # decide date and duration range
    if @recorded_sessions.blank?
      @default_date_min = 120
      @default_duration_min = 0
      @default_duration_max = 60
    else
      @default_date_min = ((Time.now - @recorded_sessions.minimum(:created_at)) / 86400).ceil
      @default_duration_min = @recorded_sessions.minimum(:duration).floor
      @default_duration_max = @recorded_sessions.maximum(:duration).ceil
    end
    @default_date_max = 0

    date_min = params[:'date-min'] ? params[:'date-min'].to_i.days.ago : @default_date_min.days.ago
    date_max = params[:'date-max'] ? params[:'date-max'].to_i.days.ago : @default_date_max.days.ago
    duration_min = params[:'duration-min'] || @default_duration_min
    duration_max = params[:'duration-max'] || @default_duration_max

    @recorded_sessions = @recorded_sessions.duration_between(duration_min, duration_max)
    @recorded_sessions = @recorded_sessions.date_between(date_min, date_max)
    if not params[:properties].blank?
      parts = params[:properties].split(':')
      num_parts = parts.count
      case num_parts
      when 1
        # search both key and value with the same input
        keyword = parts[0].strip
        @recorded_sessions = @recorded_sessions.has_property_key_or_value(keyword)
      when 2
        @recorded_sessions = @recorded_sessions.has_property(parts[0].strip, parts[1].strip)
      else
        keyword = params[:properties].strip
        @recorded_sessions = @recorded_sessions.has_property_key_or_value(keyword)
      end
    end

    @recorded_sessions = @recorded_sessions.where(:app_version => versions, :app_build => builds)
    if params[:favorite] == "1"
      @recorded_sessions = @recorded_sessions.favorite_of(current_user)
    end
    @favorite_count = @recorded_sessions.favorite_of(current_user).count
    @recorded_sessions = @recorded_sessions.latest.page(params[:page]).per(10)

    app_sessions_id = @recorded_sessions.collect { |as| as.id }
    @favorite_app_sessions = AppSession.joins(:favorites).select('DISTINCT app_sessions.id').where(:'favorites.user_id' => current_user, :'app_sessions.id' => app_sessions_id)
    @favorite_app_session_ids = @favorite_app_sessions.collect { |as| as.id }

    @last_viewed_at = @app.last_viewed_at_by_user(current_user)
    @app.log_view(current_user)

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
    if state == '1'  # convert to 'true' or 'false'
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
