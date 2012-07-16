require "spec_helper"

describe OrientationTracksController do
  describe "routing" do

    it "routes to #create" do
      post("/orientation_tracks").should route_to("orientation_tracks#create")
    end

  end
end
