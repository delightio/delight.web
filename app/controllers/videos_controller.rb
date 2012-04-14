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
end
