class VideosController < ApplicationController
  def create
    @video = Video.new params[:video]

    respond_to do |format|
      if @video.save
        format.xml # TODO: should use custom show.xml. We also don't return the right status code
      else
        format.xml { render xml: @video.errors, status: :bad_request }
      end
    end
  end
end
