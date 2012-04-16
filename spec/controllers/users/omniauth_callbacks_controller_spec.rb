require 'spec_helper'

describe Users::OmniauthCallbacksController do

  describe "GET 'twitter'" do
    it "returns http success" do
      get 'twitter'
      response.should be_success
    end
  end

  describe "GET 'github'" do
    it "returns http success" do
      get 'github'
      response.should be_success
    end
  end

end
