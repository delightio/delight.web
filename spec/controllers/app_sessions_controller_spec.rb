require 'spec_helper'

describe AppSessionsController do
  describe "post" do
    let(:app_version) { "1.4" }
    let(:delight_version) { "0.1" }
    let(:locale) { "en-US" }

    it "creates AppSession" do
      app = FactoryGirl.create :app
      params = { app_token: app.token,
                 app_version: app_version,
                 locale: locale,
                 delight_version: delight_version }
      post :create, params
      response.should be_success
    end

    it "returns 400 if missing parameters" do
      post :create
      response.should_not be_success
    end
  end
end