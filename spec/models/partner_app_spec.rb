require 'spec_helper'

describe PartnerApp do
  subject { FactoryGirl.create :partner_app }

  describe '#recording?' do
    it 'only depends on account credits and if recording is paused' do
      subject.schedule_recordings 0

      subject.should be_recording
    end
  end
end