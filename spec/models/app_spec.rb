require 'spec_helper'

describe App do

  let(:name) { "Nowbox" }
  subject { FactoryGirl.create :app }
  its(:token) { should_not be_empty }

  describe "#generate_token" do
    it "returns unique token"
  end

  describe '#recording?' do
    context 'when we have no credits' do
      it 'is always false'
    end

    context 'when we have credits' do
      it 'is true when recording is not paused'
      it 'is false when recording is paused'
    end
  end

  describe '#uploading_on_wifi_only?' do
    it 'is true if setting says yes'
    it 'is false if setting says no'
  end
end