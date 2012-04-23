class VideosController < ApplicationController
  def create
    if params[:video].nil?
      render xml: "Missing video key", status: :bad_request
      return
    end

    @video = Video.new params[:video]

    respond_to do |format|
      if @video.save
        format.xml # TODO: should use custom show.xml. We also don't return the right status code
      else
        format.xml { render xml: @video.errors, status: :bad_request }
      end
    end
  end

  def show
    authenticate_user!
    @video = Video.find(params[:id]) # throws exception if not found
    app = @video.app_session.app
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

end
