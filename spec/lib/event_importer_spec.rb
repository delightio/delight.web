require 'spec_helper'

describe EventImporter do
  it "should import event of plist" do
    filename = File.join(Rails.root, 'spec', 'fixtures', 'event_track.plist')
    file = File.open(filename)
    events = EventImporter.new(file).events

    expect = [
      ["account_viewed", 4.5723352440109011, [["name", "Olga Orange"]]],
      ["account_added", 17.915507944009732, [["email", "t@pun.io"], ["name", "thomas"]]],
      ["account_viewed", 19.145736510006827, [["name", "Wade White"]]],
    ]

    actual = events.map do |event|
      properties = event.properties.map {|property| [property[0], property[1]]}
      [event.name, event.time, properties]
    end

    actual.should == expect
  end
end