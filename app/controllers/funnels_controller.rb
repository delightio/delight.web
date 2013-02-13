class FunnelsController < ApplicationController
  before_filter :find_app

  def new
    @funnel = @app.funnels.build
  end

  def create
    @funnel = @app.funnels.build(params[:funnel])
    @funnel.save!
    redirect_to @app, notice: 'Funnel was successfully created.'
  end

  def edit
    @funnel = @app.funnels.find(params[:id])
  end

  def update
    @funnel = @app.funnels.find(params[:id])
    @funnel.update_attributes!(params[:funnel])
    redirect_to @app, notice: 'Funnel was successfully updated.'
  end

  def destroy
    @funnel = @app.funnels.find(params[:id])
    @funnel.destroy
    redirect_to @app, notice: 'Funnel was successfully destroyed.'
  end

private
  def find_app
    @app = App.find(params[:app_id])
  end
end