class VideosController < ScreenTracksController
  before_filter :rename_params

  def rename_params
    params[model_param_key] = params[:video]
    params[model_param_key].delete :uri # previous version has uri
    params.delete :video
  end
end
