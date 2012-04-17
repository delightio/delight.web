require 'spec_helper'

describe "BetaSignups" do
  describe "POST /beta_signups" do
    it "creates beta signup" do
      post '/beta_signups.json'
      response.should be_success
    end
  end
end
