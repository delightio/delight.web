require 'spec_helper'

describe VideosController do
  let(:path) { "abc" }
  describe "post" do
    it "creates new video object" do
      params = { url: path }
      post :create, video: params
      response.should be_success
    end

    it "returns 400 if missing parameters" do
      post :create, video: {}
      response.should_not be_success
    end
  end
end
