require 'spec_helper'

describe UsabilityAppSession do
  subject { FactoryGirl.create :usability_app_session }

  describe '#upload_tracks' do
    context 'when delight version is equal or newer than 3.0' do
      before { subject.stub :delight_version => '3.0' }
      it 'contains a front track besides a screen, touch, orientation, view and event track' do
        upload_tracks = subject.upload_tracks

        upload_tracks.should include :front_track

        upload_tracks.should include :screen_track
        upload_tracks.should include :touch_track
        upload_tracks.should include :orientation_track
        upload_tracks.should include :event_track
        upload_tracks.should include :view_track
      end
    end

    context 'when delight version is older than 2.2' do
      before { subject.stub :delight_version => '2.2.2' }
      it 'still contains a front track' do
        subject.upload_tracks.should include :front_track
      end
    end
  end

  describe '#cost' do
    it 'is twice the duration since it includes front track' do
      subject.cost.should == (2 * subject.duration)
    end
  end
end