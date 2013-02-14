class EventImporter
  attr_accessor :data

  def initialize(file)
    @data = Plist::parse_xml(file)
  end

  def import(app_session)
    app = app_session.app
    data = @data

    app_session.class.transaction do
      data["events"].each do |data|
        event = app.events.find_or_create_by_name!(data["name"])
        event.event_infos.create!({
          app_session: app_session,
          time: data["time"],
          properties: data["properties"]
        })
      end
    end
  end
end