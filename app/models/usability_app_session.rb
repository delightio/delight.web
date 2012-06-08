class UsabilityAppSession < AppSession
  def upload_tracks
    [:screen_track, :touch_track, :orientation_track, :front_track]
  end

  def maximum_duration
    2.hours
  end
end