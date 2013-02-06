require "spec_helper"

describe ViewTracksController do
  describe "routing" do

    it "routes to #create" do
      post("/view_tracks").should route_to("view_tracks#create")
    end

  end
end
