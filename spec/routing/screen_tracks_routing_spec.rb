require "spec_helper"

describe ScreenTracksController do
  describe "routing" do

    it "routes to #create" do
      post("/screen_tracks").should route_to("screen_tracks#create")
    end

  end
end
