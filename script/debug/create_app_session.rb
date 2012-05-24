require File.expand_path('config/environment.rb')

if ARGV.count != 1
  puts "We need APP_ID"
end

app_id = ARGV.shift

app_session = AppSession.create delight_version: '2.0',
                                app_id: app_id,
                                app_version: '0.2',
                                app_build: 'ABC',
                                app_locale: 'en-HK',
                                app_connectivity: 'wifi',
                                device_hw_version: 'x',
                                device_os_version: '5.0',
                                duration: 22

puts "AppSession[#{app_session.id}] created."
puts "Please make sure the followings are in #{ENV['S3_UPLOAD_BUCKET']} on S3:"
[ScreenTrack, TouchTrack, PresentationTrack].each do |track_class|
  track = track_class.create app_session: app_session
  puts "  #{track.filename}"
  if track_class==PresentationTrack
    puts "  #{track.thumbnail.filename}"
  end
end
