class EventTrackParsing
  extend WithDatabaseConnection
  @queue = :event_track

  def self.perform app_session_id
    app_session = AppSession.find(app_session_id)
    event = app_session.event_track.download

    event_data = Plist::parse_xml(event)

    app_session.class.transaction do
      event_data["eventOccured"].each do |data|
        app_session.events.create!(name: data["name"])
      end
    end
  end

  def self.enqueue app_session_id
    Resque.enqueue self, app_session_id
  end
end