require 'spec_helper'

describe ViewTracksController do
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new event track object" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = app_session.app.token
      params = { app_session_id: app_session.id }
      post :create, format: :xml, view_track: params
      response.should be_success
      #response.response_code.should == 201
    end

    it "returns 400 if missing parameters" do
      post :create, view_track: {}
      response.should_not be_success
    end
  end
end
