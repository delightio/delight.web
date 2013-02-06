require "spec_helper"

describe TouchTracksController do
  describe "routing" do

    it "routes to #create" do
      post("/touch_tracks").should route_to("touch_tracks#create")
    end

  end
end
