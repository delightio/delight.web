require 'spec_helper'

describe FrontTracksController do
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new front track object" do
      params = { app_session_id: app_session.id }
      post :create, format: :xml, front_track: params
      response.should be_success
      #response.response_code.should == 201
    end

    it "returns 400 if missing parameters" do
      post :create, front_track: {}
      response.should_not be_success
    end
  end
end
