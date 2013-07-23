class UsabilityAppSession < AppSession
  def upload_tracks
    super << :front_track
  end
end