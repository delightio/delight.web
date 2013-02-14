require 'spec_helper'

describe EventImporter do
  let(:importer) do
    filename = File.join(Rails.root, 'spec', 'fixtures', 'event_track.plist')
    file = File.open(filename)

    EventImporter.new(file)
  end

  let(:imported_data) do
    {
      "events" => [
        {
          "name" => "account_viewed",
          "properties" => {
            "name" => "Olga Orange"
          },
          "time" => 4.572335244010901
        },{
          "name" => "account_added",
          "properties" => {
            "email" => "t@pun.io",
            "name" => "thomas"
          },
          "time" => 17.915507944009732
        },{
          "name" => "account_viewed",
          "properties" => {
            "name" => "Wade White"
          },
        "time" => 19.145736510006827
        }
      ]
    }
  end

  subject { importer }

  it "should import event of plist" do
    importer.data.should == imported_data
  end

  describe '#import_events' do
    let(:app_session) do
      FactoryGirl.create :app_session
    end

    before do
      event_track = FactoryGirl.create :event_track, app_session: app_session
    end

    it 'should save imported event data' do
      subject.stub(:data) { imported_data }
      subject.import(app_session)

      app_session.events.map(&:name).should == ["account_viewed", "account_added"]
      app_session.event_infos.map{|info| [info.event.name, info.time, info.properties]} == [
        ["account_viewed", 4.572335244010901, {"name" => "Olga Orange"}],
        ["account_added", 17.915507944009732, {"email" => "t@pun.io", "name" => "thomas"}],
        ["account_viewed", 19.145736510006827, {"name" => "Wade White"}],
      ]
    end
  end

end