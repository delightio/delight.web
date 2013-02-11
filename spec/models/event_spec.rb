require 'spec_helper'

describe Event do
  before do
    @valid_attributes ={
      name: "good_event",
      time: 9.3939
    }
  end

  it "should create a new install with valid attributes" do
    event = Event.new(@valid_attributes)
    event.should be_valid
  end

  it "shouldn't create a new install with valid attributes" do
    event = Event.new(@valid_attributes.merge(name: nil))
    event.should be_invalid

    event = Event.new(@valid_attributes.merge(time: nil))
    event.should be_invalid
  end

  describe "#by_properties" do
    it "should find events by properties" do
      event1 = Event.create!(@valid_attributes.merge(properties: {name: "Paul", age: "20"}))
      event2 = Event.create!(@valid_attributes.merge(properties: {name: "Paul", age: "18"}))
      event3 = Event.create!(@valid_attributes.merge(properties: {name: "John", age: "20"}))

      Event.by_properties(name: "Paul").should == [event1, event2]
      Event.by_properties(name: "Paul", age: "20").should == [event1]
      Event.by_properties(age: "20").should == [event1, event3]
    end
  end
end