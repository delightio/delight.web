class OrientationTracksController < TracksController
  def model_class
    OrientationTrack
  end

  def model_param_key
    :orientation_track
  end
end
