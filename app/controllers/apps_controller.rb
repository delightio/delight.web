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
# TODO: seperate session retrieval, move scope from app to app_sessions
    date_min = params[:'date-min'] ? params[:'date-min'].to_i.days.ago : nil
    date_max = params[:'date-max'] ? params[:'date-max'].to_i.days.ago : nil

    if current_user.administrator?
      @app ||= App.includes(:app_sessions).administered_by(current_user).find(params[:id])
    end

    # viewers
    @app ||= App.includes(:app_sessions).viewable_by(current_user).find(params[:id])

    @app_sessions = @app.app_sessions.duration_between(params[:'duration-min'], params[:'duration-max'])

    if params[:'date-min'] and params[:'date-max']
      @app_sessions = @app_sessions.date_between(
        params[:'date-min'].to_i.days.ago,
        params[:'date-max'].to_i.days.ago
      )
    end

    if params[:versions]
      @app_sessions = @app_sessions.where(:app_version => params[:versions])
    end

    @app_sessions = @app_sessions.order('app_sessions.created_at DESC')

    respond_to do |format|
      format.html # show.html.erb
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
