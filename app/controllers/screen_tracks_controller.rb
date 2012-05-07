class ScreenTracksController < TracksController
  def model_class
    ScreenTrack
  end

  def model_param_key
    :screen_track
  end
end
