require 'spec_helper'

describe Scheduler do
  subject { Scheduler.create app_id: 10 }

  describe '#completed?' do
    it 'is true when we recorded more than the scheduled number of recording' do
      subject.scheduled = 5
      subject.recorded = 5

      subject.should be_completed
    end

    it 'is false when we recorded fewer than the scheduled' do
      subject.scheduled = 5
      subject.recorded = 4

      subject.should_not be_completed
    end

    it 'is false when we have not scheduled or recorded any' do
      subject.should_not be_completed
    end
  end

  describe '#recording?' do
    it 'is true if the state is recording and we have not completed' do
      subject.schedule 10
      subject.record 5
      subject.state = 'recording'

      subject.should be_recording
    end

    it 'is false if the state is recording but we have already completed' do
      subject.schedule 5
      subject.record 5
      subject.state = 'recording'

      subject.should_not be_recording
    end

    it 'is false if the state is not recording' do
      subject.state = 'paused'

      subject.should_not be_recording
    end
  end

  describe '#schedule' do
    it 'sets scheduled' do
      subject.schedule 10

      Scheduler.find(subject.id).scheduled.should == 10
    end

    it 'automatically starts recording'

    it 'resets number of recorded' do
      subject.record 10

      expect { subject.schedule 10 }.
        to change { subject.recorded }.from(10).to(0)
    end

    it 'resets notification email' do
      subject.notify_users

      expect { subject.schedule 10 }.
        to change { subject.notified_at }.to(nil)
    end
  end

  describe '#record' do
    it 'increments recorded' do
      subject.record 10
      subject.record 10

      Scheduler.find(subject.id).recorded.should == 20
    end

    it 'notifies users when completed' do
      subject.schedule 10
      subject.should_receive :notify_users

      subject.record 10
    end
  end

  describe '#remaining' do
    it 'returns the number of recordings to be done' do
      subject.schedule 10
      subject.record 7

      subject.remaining.should == 3
    end

    it 'is always non negative' do
      subject.schedule 5
      subject.record 7

      subject.remaining.should == 0
    end
  end

  describe '#pause' do
    it 'pauses the recording' do
      subject.pause

      subject.should_not be_recording
    end
  end

  describe '#resume' do
    it 'resumes the recording and set recording? to be true' do
      subject.resume

      subject.should be_recording
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
