class UsabilityAppSession < AppSession
  def upload_tracks
    [:screen_track, :touch_track, :orientation_track, :front_track]
  end

  def credits
    2
  end
end