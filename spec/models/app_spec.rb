require 'spec_helper'

describe App do

  let(:name) { "Nowbox" }
  subject { App.create name:name }
  its(:token) { should_not be_empty }

  describe "#generate_token" do
    it "returns unique token"
  end
end