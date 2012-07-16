require "spec_helper"

describe EventTracksController do
  describe "routing" do

    it "routes to #create" do
      post("/event_tracks").should route_to("event_tracks#create")
    end

  end
end
