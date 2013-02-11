class EventImporter
  attr_reader :events

  def initialize(file)
    event_data = Plist::parse_xml(file)

    @events = event_data["events"].map do |data|
      Event.new({
        name: data["name"],
        time: data["time"],
        properties: data["properties"]
      })
    end
  end
end