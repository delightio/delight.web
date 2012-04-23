require "spec_helper"

describe AppSessionsController do
  describe "routing" do

    it "routes to #show" do
      get("/app_sessions/1").should route_to("app_sessions#show", :id => "1")
    end

    it "routes to #create" do
      post("/app_sessions").should route_to("app_sessions#create")
    end

    it "routes to #update" do
      put("/app_sessions/1").should route_to("app_sessions#update", :id => "1")
    end

  end
end
