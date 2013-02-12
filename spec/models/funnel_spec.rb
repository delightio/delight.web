require 'spec_helper'

describe Funnel, focus: true do
  before do
    @valid_attributes ={
      name: "good_event"
    }
  end

  it "should create a new install with valid attributes" do
    funnel = Funnel.new(@valid_attributes)
    funnel.should be_valid
  end

  it "shouldn't create a new install with valid attributes" do
    funnel = Funnel.new(@valid_attributes.merge(name: nil))
    funnel.should be_invalid
  end

  describe "#app_sessions" do
    it "should find app sessions by events" do
      session1 = FactoryGirl.create :app_session_with_event_track
      session2 = FactoryGirl.create :app_session_with_event_track

      event1 = session1.events.create!(name: "item-selected", time: 1.0)
      event2 = session2.events.create!(name: "item_purchased", time: 2.0)

      funnel1 = Funnel.create!(name: "test")
      funnel2 = Funnel.create!(name: "test2")

      funnel1.events << event1
      funnel2.events << event2

      funnel1.app_sessions.should == [session1]
      funnel2.app_sessions.should == [session2]
    end
  end
end