require 'spec_helper'

describe VideosController do
  let(:uri) { "abc" }
  let(:app_session) { FactoryGirl.create :app_session}
  describe "post" do
    it "creates new video object" do
      params = { uri: uri, app_session_id: app_session.id }
      post :create, format: :xml, video: params
      response.should be_success
    end

    it "returns 400 if missing parameters" do
      post :create, video: {}
      response.should_not be_success
    end
  end
end
