require File.expand_path('config/environment.rb')

if ARGV.count != 1
  puts "We need at least a app session id. Destionation directory and buckect name are optional"
end

app_session_id = ARGV.shift
destination = ARGV.shift || '/tmp'
delight_upload = ARGV.shift || 'delight_upload'

track_classes = [ScreenTrack, TouchTrack, OrientationTrack, FrontTrack,
                 PresentationTrack, GestureTrack]

track_classes.each do |track_class|
  begin
    track = track_class.new app_session_id: app_session_id
    s3 = S3Storage.new track.filename, delight_upload
    puts "Downloading #{track.filename} to #{destination}..."
    s3.download destination
  rescue => e
    puts "  Skipping #{track.filename}: #{e.inspect}"
  end
end