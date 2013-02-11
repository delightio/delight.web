class VideoProcessing
  extend WithDatabaseConnection
  @queue = :video

  def self.perform app_session_id
    start = Time.now

    puts "AppSession[#{app_session_id}] is processing..."
    app_session = AppSession.find app_session_id

    touch = app_session.touch_track.download
    screen = app_session.screen_track.download
    event = app_session.event_track.download
    rotation = app_session.orientation_track.rotation app_session.duration.to_i

    if app_session.front_track
      front_track = app_session.front_track
      front = front_track.download
      rotate_video front, rotation
      front_track.upload front
    end

    app_session.import_events EventImporter.new(event).events

    gesture_converter = GestureConverter.new touch
    gesture = gesture_converter.dump app_session.working_directory

    processed = VideoProcessing.draw_touch screen, touch, rotation
    thumbnail = VideoProcessing.thumbnail processed, rotation

    app_session.destroy_presentation_track
    app_session.destroy_gesture_track

    presentation_track = PresentationTrack.new app_session: app_session
    presentation_track.upload processed
    presentation_track.thumbnail.upload thumbnail

    gesture_track = GestureTrack.new app_session: app_session
    gesture_track.upload gesture

    if gesture_track.save && presentation_track.save
      puts "AppSession[#{app_session_id}]: done processing in #{Time.now-start} s."
    end

    # cleanup app_session.working_directory
  end

  def self.enqueue app_session_id
    Resque.enqueue VideoProcessing, app_session_id
    puts "AppSession[#{app_session_id}] is enqueued for VideoProcessing"
  end

  # TODO
  def self.draw_touch screen_file, touch_file, rotation_angle
    processed_filename = "#{screen_file.path}.draw_touch.mov"
    `gesturedrawer -f "#{screen_file.path}" -p "#{touch_file.path}" -d "#{processed_filename}"`
    rotate_video processed_filename, rotation_angle
    VideoFile.new processed_filename
  end

  def self.rotate_video mp4_file, rotation_angle
    `qtrotate.py "#{mp4_file}" "#{rotation_angle}"`
  end

  def self.thumbnail video_file, rotation_angle
    dimension = "#{video_file.width}x#{video_file.height}"
    thumbnail_filename = video_file.path+'.thumbnail.png'
    transpose = case rotation_angle
                when 90
                  "-vf transpose=1"
                when 270
                  "-vf transpose=2"
                when 180
                  "-vf vflip"
                else
                  ""
                end
    `ffmpeg -itsoffset 4 -i "#{video_file.path}" -vcodec png #{transpose} -vframes 1 -an -f rawvideo -s #{dimension} -y "#{thumbnail_filename}"`
    File.new thumbnail_filename
  end

  def self.cleanup working_directory
    FileUtils.remove_dir working_directory, true
  end
end