require 'spec_helper'

class VideosController < ApplicationController
  def create
    @video = Video.new params[:video]

    if @video.save
      render json: @video, status: :created
    else
      render json: @video.errors, status: :bad_request
    end
  end
end
