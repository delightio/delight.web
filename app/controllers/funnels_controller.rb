class FunnelsController < ApplicationController
  before_filter :find_app

  def new
    @funnel = @app.funnels.build
  end

  def create
    @funnel = @app.funnels.build(params[:funnel])
    @funnel.save!
    redirect_to @app
  end

private
  def find_app
    @app = App.find(params[:app_id])
  end
end