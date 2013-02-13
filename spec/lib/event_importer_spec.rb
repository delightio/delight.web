require 'spec_helper'

describe EventImporter do
  it "should import event of plist" do
    filename = File.join(Rails.root, 'spec', 'fixtures', 'event_track.plist')
    file = File.open(filename)

    importer = EventImporter.new(file)

    events = importer.events.map {|event| event.name}
    event_infos = importer.events.map do |event|
      event.event_infos.map {|info| [info.time.to_f.round(5), info.properties]}
    end

    events.should == ["account_viewed", "account_added"]
    event_infos.should == [
      [
        [4.57234, {"name" => "Olga Orange"}],
        [19.14574, {"name" => "Wade White"}]
      ],
      [
        [17.91551, {"email" => "t@pun.io", "name" => "thomas"}]
      ],
    ]
  end
end