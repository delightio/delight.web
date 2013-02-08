class EventTrackParsing
  extend WithDatabaseConnection
  @queue = :event_track

  def self.perform app_session_id
    start = Time.now
    puts "AppSession[#{app_session_id}] is processing..."

    app_session = AppSession.find(app_session_id)
    event = app_session.event_track.download

    event_data = Plist::parse_xml(event)

    app_session.class.transaction do
      event_data["events"].each do |data|
        app_session.events.create!({
          name: data["name"],
          time: data["time"]
        })
      end
    end

    puts "AppSession[#{app_session_id}]: done processing in #{Time.now-start} s."
  end

  def self.enqueue app_session_id
    Resque.enqueue self, app_session_id
    puts "AppSession[#{app_session_id}] is enqueued for EventTrackParsing"
  end
end