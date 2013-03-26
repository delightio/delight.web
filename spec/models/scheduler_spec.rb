require 'spec_helper'

describe Scheduler do
  subject { Scheduler.create app_id: 10 }

  describe '#recording?' do
    it 'reports state of recording' do
      subject.update_attributes recording: true

      subject.should be_recording
    end
  end

  describe '#start_recording' do
    it 'starts recording' do
      subject.start_recording

      subject.should be_recording
    end
  end

  describe '#stop_recording' do
    it 'stops the recording' do
      subject.stop_recording

      subject.should_not be_recording
    end
  end

  describe '#notify_users' do
    it 'enqueues completion email' do
      Resque.should_receive(:enqueue).once.
        with(AppRecordingCompletion, subject.app_id)

      subject.notify_users
    end
  end

  describe '#notified?' do
    it 'is true if we have previously notified users on completion' do
      subject.notify_users

      subject.should be_notified
    end
  end
end
