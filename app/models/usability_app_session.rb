class UsabilityAppSession < AppSession
  def upload_tracks
    super << :front_track
  end

  def cost
    2 * duration.to_f # both screen and front tracks
  end
end