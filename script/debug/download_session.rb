require File.expand_path('config/environment.rb')

if ARGV.count != 2
  puts "We need app session id and a destination directory"
end

app_session_id = ARGV.shift
destination = ARGV.shift
delight_upload = ARGV.shift || 'delight_upload'

track_classes = [ScreenTrack, TouchTrack, OrientationTrack, FrontTrack,
                 PresentationTrack]

track_classes.each do |track_class|
  begin
    track = track_class.new app_session_id: app_session_id
    s3 = S3Storage.new track.filename, delight_upload
    puts "Downloading #{track.filename} to #{destination}..."
    s3.download destination
  rescue
    puts '  not found. skipping...'
  end
end