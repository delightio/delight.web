require "spec_helper"

describe BetaSignupsController do
  describe "routing" do

    it "routes to #create" do
      post("/beta_signups").should route_to("beta_signups#create")
    end

  end
end
