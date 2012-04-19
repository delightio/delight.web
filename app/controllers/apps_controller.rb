class AppsController < ApplicationController
  before_filter :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    flash[:type] = 'error'
    flash[:notice] = 'Invalid operation'
    redirect_to :action => :index
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
  def show
    @app = nil
    if current_user.administrator?
      @app ||= App.includes(:app_sessions).administered_by(current_user).find(params[:id])
    end

    # viewers
    @app ||= App.includes(:app_sessions).viewable_by(current_user).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
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

end
