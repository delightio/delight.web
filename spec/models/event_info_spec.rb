require 'spec_helper'

describe EventInfo do
  before do
    @valid_attributes ={
      app_session_id: 1,
      event_id: 2,
      track_id: 3,
      time: 10.0,
      properties: {
        "name" => "John Doe"
      }
    }

    EventInfo.any_instance.stub(:associate_track) {}
  end

  it "should create a new install with valid attributes" do
    event_info = EventInfo.new(@valid_attributes)
    event_info.should be_valid
  end

  it "shouldn't create a new install with valid attributes" do
    event_info = EventInfo.new(@valid_attributes.merge(app_session_id: nil))
    event_info.should be_invalid

    event_info = EventInfo.new(@valid_attributes.merge(event_id: nil))
    event_info.should be_invalid

    event_info = EventInfo.new(@valid_attributes.merge(track_id: nil))
    event_info.should be_invalid
  end

  describe "#by_properties" do
    it "should find events by properties" do
      event1 = EventInfo.create!(@valid_attributes.merge(properties: {name: "Paul", age: "20"}))
      event2 = EventInfo.create!(@valid_attributes.merge(properties: {name: "Paul", age: "18"}))
      event3 = EventInfo.create!(@valid_attributes.merge(properties: {name: "John", age: "20"}))

      EventInfo.by_properties(name: "Paul").should == [event1, event2]
      EventInfo.by_properties(name: "Paul", age: "20").should == [event1]
      EventInfo.by_properties(age: "20").should == [event1, event3]
    end
  end
end