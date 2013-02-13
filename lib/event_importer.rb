class EventImporter
  attr_accessor :events, :event_infos

  def initialize(file)
    event_data = Plist::parse_xml(file)
    import(event_data)
  end

private
  def import(event_data)
    @events = event_data["events"].map do |data|
      Event.new({
        name: data["name"],
      })
    end

    @events.uniq!(&:name)

    @event_infos = event_data["events"].map do |data|
      event = @events.find {|event| event.name == data["name"]}

      event_info = event.event_infos.build({
        time: data["time"],
        properties: data["properties"],
      })
    end
  end
end