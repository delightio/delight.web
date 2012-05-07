require 'spec_helper'

describe TouchTracksController do
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new touch track object" do
      params = { app_session_id: app_session.id }
      post :create, format: :xml, touch_track: params
      response.should be_success
      #response.response_code.should == 201
    end

    it "returns 400 if missing parameters" do
      post :create, touch_track: {}
      response.should_not be_success
    end
  end
end
