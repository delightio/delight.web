class VideoProcessing
  extend WithDatabaseConnection
  @queue = :video

  def self.perform app_session_id
    app_session = AppSession.find app_session_id

    touch = app_session.touch_track.download
    screen = app_session.screen_track.download

    processed = VideoProcessing.draw_touch touch, screen
    thumbnail = VideoProcessing.thumbnail processed

    presentation_track = PresentationTrack.new app_session: app_session
    presentation_track.upload encoded
    presentation_track.thumbnail.upload thumbnail
    presentation_track.save
  end

  def self.enqueue app_session_id
    Resque.enqueue VideoProcessing, app_session_id
  end

  # TODO
  def self.draw_touch touch_file, screen_file
    screen_file
  end

  def self.thumbnail video_file
    video_file
  end
end