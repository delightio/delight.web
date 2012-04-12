require 'spec_helper'

describe AppSessionsController do
  describe "post" do
    let(:app) { FactoryGirl.create :app }
    let(:app_version) { "1.4" }
    let(:delight_version) { "0.1" }
    let(:locale) { "en-US" }

    it "creates" do
      params = { app_token: app.token,
                 app_version: app_version,
                 locale: locale,
                 delight_version: delight_version }
      post :create, app_session: params
      response.should be_success
    end

    it "returns 400 if missing parameters" do
      post :create, app_session: {}
      response.should_not be_success
    end
  end

  describe "put" do
    let(:app_session) { FactoryGirl.create :app_session }

    let(:duration) { 10.2 }
    it "updates duration" do
      params = { duration: duration }
      put :update, id: app_session.id, app_session: params
      response.should be_success
      app_session.reload.duration.should == duration
    end

    let(:app_user_id) { "10" }
    it "updates app_user_id" do
      params = { app_user_id: app_user_id }
      put :update, id: app_session.id, app_session: params
      response.should be_success
      app_session.reload.app_user_id.should == app_user_id
    end

    let(:video_uri) { "http://abc.mp4" }
    it "updates video association" do
      params = { video_uri: video_uri }
      put :update, id: app_session.id, app_session: params
      response.should be_success
      app_session.reload.video.uri.should == video_uri
    end
  end
end