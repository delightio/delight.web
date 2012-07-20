require 'spec_helper'

describe UsabilityAppSession do
  subject { FactoryGirl.create :usability_app_session }
  describe '#upload_tracks' do
    it 'contains front_track' do
      subject.upload_tracks.should include :front_track

      subject.upload_tracks.should include :screen_track
      subject.upload_tracks.should include :touch_track
      subject.upload_tracks.should include :orientation_track
    end
  end

  its(:credits) { should == 2 }
end