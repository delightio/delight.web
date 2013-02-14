require 'spec_helper'

describe Funnel do
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
end