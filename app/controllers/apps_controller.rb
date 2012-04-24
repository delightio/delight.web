class AppsController < ApplicationController
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
    @viewer_apps = App.viewable_by(current_user).all
    if current_user.administrator?
      @admin_apps = App.administered_by(current_user).all
    else
      @admin_apps = nil
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /apps/1
  # GET /apps/1.js
  def show
    @app = nil

    @default_date_min = 120
    @default_date_max = 0
    @default_duration_min = 0
    @default_duration_max = 60

    date_min = params[:'date-min'] ? params[:'date-min'].to_i.days.ago : @default_date_min.days.ago
    date_max = params[:'date-max'] ? params[:'date-max'].to_i.days.ago : @default_date_max.days.ago
    duration_min = params[:'duration-min'] || @default_duration_min
    duration_max = params[:'duration-max'] || @default_duration_max

    logger.debug("date min: #{date_min}, date max: #{date_max}, duration min: #{duration_min}, duration max: #{duration_max}")

    if current_user.administrator?
      @app ||= App.includes(:app_sessions).administered_by(current_user).find(params[:id])
    end

    # viewers
    @app ||= App.includes(:app_sessions).viewable_by(current_user).find(params[:id])
    @versions = @app.app_sessions.select('app_sessions.app_version, count(1)').group(:'app_sessions.app_version')
    versions = params[:versions] || @versions.collect { |v| v.app_version }

    @app_sessions = @app.app_sessions
                    .duration_between(duration_min, duration_max)
                    .date_between(date_min, date_max)
                    .where(:app_version => versions)
                    .order('app_sessions.created_at DESC')

    app_sessions_id = @app_sessions.collect { |as| as.id }
    @favorite_app_session = AppSession.joins(:favorites).select('DISTINCT app_sessions.id').where(:'favorites.user_id' => current_user, :'app_sessions.id' => app_sessions_id)
    @favorite_app_session_ids = @favorite_app_session.collect { |as| as.id }


    respond_to do |format|
      format.html do
        render # show.html.erb
      end
      format.js # show.html.js
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
        @app.schedule_recordings 100

        flash[:notice] = 'App was successfully created.'
        format.html { redirect_to :action => :index }
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
    @app = App.administered_by(current_user).find(params[:app_id])

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

end
