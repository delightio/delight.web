class VideoProcessing
  extend WithDatabaseConnection
  @queue = :video

  def self.perform app_session_id
    start = Time.now

    puts "AppSession[#{app_session_id}] is processing..."
    app_session = AppSession.find app_session_id

    touch = app_session.touch_track.download
    screen = app_session.screen_track.download

    processed = VideoProcessing.draw_touch screen, touch
    thumbnail = VideoProcessing.thumbnail processed

    presentation_track = PresentationTrack.new app_session: app_session
    presentation_track.upload processed
    presentation_track.thumbnail.upload thumbnail
    if presentation_track.save
      puts "AppSession[#{app_session_id}]: done processing in #{Time.now-start} s."
    end

    cleanup app_session.working_directory
  end

  def self.enqueue app_session_id
    Resque.enqueue VideoProcessing, app_session_id
    puts "AppSession[#{app_session_id}] is enqueued for VideoProcessing"
  end

  # TODO
  def self.draw_touch screen_file, touch_file
    processed_filename = "#{screen_file.path}.draw_touch.mov"
    `gesturedrawer -f "#{screen_file.path}" -p "#{touch_file.path}" -d "#{processed_filename}"`
    VideoFile.new processed_filename
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