class EventTrackParsing
  extend WithDatabaseConnection
  @queue = :event_track

  def self.perform app_session_id
    start = Time.now
    puts "AppSession[#{app_session_id}] is processing..."

    app_session = AppSession.find(app_session_id)
    event = app_session.event_track.download

    app_session.events << EventImporter.new(event).events

    puts "AppSession[#{app_session_id}]: done processing in #{Time.now-start} s."
  end

  def self.enqueue app_session_id
    Resque.enqueue self, app_session_id
    puts "AppSession[#{app_session_id}] is enqueued for EventTrackParsing"
  end
end