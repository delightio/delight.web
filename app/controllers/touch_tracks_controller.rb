class TouchTracksController < TracksController
  def model_class
    TouchTrack
  end

  def model_param_key
    :touch_track
  end
end
