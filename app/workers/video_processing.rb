class VideoProcessing
  extend WithDatabaseConnection
  @queue = :video

  def self.perform app_session_id
    start = Time.now
    puts "AppSession[#{app_session_id}] is processing..."

    app_session = AppSession.find app_session_id

    touch = app_session.touch_track.download
    screen = app_session.screen_track.download

    processed = VideoProcessing.draw_touch touch, screen
    thumbnail = VideoProcessing.thumbnail processed

    presentation_track = PresentationTrack.new app_session: app_session
    presentation_track.upload processed
    # presentation_track.thumbnail.upload thumbnail
    if presentation_track.save
      puts "AppSession[#{app_session_id}] is done processing in #{Time.now-start} s."
    end
  end

  def self.enqueue app_session_id
    Resque.enqueue VideoProcessing, app_session_id
    puts "AppSession[#{app_session_id}] is enqueued for VideoProcessing"
  end

  # TODO
  def self.draw_touch touch_file, screen_file
    screen_file
  end

  def self.thumbnail video_file
    video_file
  end
end