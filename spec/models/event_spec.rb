require 'spec_helper'

describe Event do
  it "should create a new install with valid attributes" do
    event = Event.new(name: "good_event")
    event.should be_valid
  end

  it "shouldn't create a new install with valid attributes" do
    event = Event.new(name: nil)
    event.should be_invalid
  end
end