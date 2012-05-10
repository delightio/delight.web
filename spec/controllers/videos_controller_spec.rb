require 'spec_helper'

describe VideosController do
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new screen track object with video params" do
      request.env['HTTP_X_NB_AUTHTOKEN'] = app_session.app.token
      params = { app_session_id: app_session.id, uri: "blah" }
      post :create, format: :xml, video: params
      response.should be_success
      #response.response_code.should == 201
    end

    it "returns 400 if missing parameters" do
      post :create, video: {}
      response.should_not be_success
    end
  end
end
