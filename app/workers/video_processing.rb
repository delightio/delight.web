class VideoProcessing
  extend WithDatabaseConnection
  @queue = :video

  def self.perform app_session_id
    puts "AppSession[#{app_session_id}] is processing..."

    app_session = AppSession.find app_session_id

    start = Time.now
    touch = app_session.touch_track.download
    screen = app_session.screen_track.download
    puts "AppSession[#{app_session_id}]: 2 tracks (TouchTrack[#{app_session.touch_track.id}], ScreenTrack[#{app_session.screen_track.id}]) downloaded in #{Time.now-start} s"

    start = Time.now
    processed = VideoProcessing.draw_touch touch, screen
    thumbnail = VideoProcessing.thumbnail processed
    puts "AppSession[#{app_session_id}]: processed in #{Time.now-start} s"

    start = Time.now
    presentation_track = PresentationTrack.new app_session: app_session
    presentation_track.upload processed
    presentation_track.thumbnail.upload thumbnail
    if presentation_track.save
      puts "AppSession[#{app_session_id}]: PresentationTrack[#{presentation_track.id}] uploaded in #{Time.now-start} s"
      puts "AppSession[#{app_session_id}]: done processing in #{Time.now-start} s."
    end

    cleanup app_session.working_directory
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
    dimension = "#{video_file.width}x#{video_file.height}"
    thumbnail_filename = video_file.path+'.thumbnail.png'
    `ffmpeg -itsoffset 4 -i "#{video_file.path}" -vcodec png -vframes 1 -an -f rawvideo -s #{dimension} -y "#{thumbnail_filename}"`
    thumbnail = File.open thumbnail_filename # TODO: may want to return a ImageFile object
    thumbnail
  end

  def self.cleanup working_directory
    FileUtils.remove_dir working_directory, true
  end
end