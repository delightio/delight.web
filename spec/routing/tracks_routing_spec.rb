require "spec_helper"

describe TracksController do
  describe "routing" do

    it "routes to #create" do
      post("/tracks").should route_to("tracks#create")
    end

  end
end
