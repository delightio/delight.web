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
end