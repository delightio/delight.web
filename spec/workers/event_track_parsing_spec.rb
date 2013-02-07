require 'spec_helper'

describe EventTrackParsing do
  subject { EventTrackParsing }
  let(:app_session) { FactoryGirl.create :uploaded_app_session }

  describe '.perform' do
    before do
      AppSession.stub(:find).with(app_session.id) { app_session }

      filename = File.join(Rails.root, 'spec', 'fixtures', 'event_track.plist')
      file = File.open(filename)
      app_session.stub_chain(:event_track, :download) { file }
    end

    it "should download .plist file, parse and insert data to events" do
      subject.perform app_session.id

      expect = ["store-shown", "item-selected", "item_purchased", "item_not_purchased"]
      actual = app_session.events.map {|event| event.name}
      actual.should == expect
    end
  end

  describe '.enqueue' do
    let(:app_session_id) { 10 }
    it 'enqueues given job on Resque' do
      Resque.should_receive(:enqueue).with(EventTrackParsing, app_session_id)
      subject.enqueue app_session_id
    end
  end
end