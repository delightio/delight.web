class FrontTracksController < TracksController
  def model_class
    FrontTrack
  end

  def model_param_key
    :front_track
  end
end
