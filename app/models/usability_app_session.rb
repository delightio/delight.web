class UsabilityAppSession < AppSession
  def upload_tracks
    super << :front_track
  end

  def credits
    2
  end
end