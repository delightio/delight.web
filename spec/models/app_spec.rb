require 'spec_helper'

describe App do

  subject { FactoryGirl.create :app }
  it { should be_recording } # We schedule recordings on creation
  its(:token) { should_not be_empty }

  describe '#generate_token' do
    it 'is a combination of random keys and own id' do
      SecureRandom.should_receive(:hex).at_least(1).and_return('FFFF')

      subject.token.should == "FFFF#{subject.id}"
    end
  end

  describe "creation" do
    it "should have some scheduled recording" do
      subject.scheduled_recordings.should > 0
    end

    it 'will record on mobile data' do
      subject.should_not be_uploading_on_wifi_only
    end

    it "should add admin as viewer" do
      subject.viewers.should include(subject.account.administrator)
    end
  end

  describe '#recording?' do
    specify 'credits have no effect' do
      subject.stub :enough_credits? => false
      subject.stub :scheduled_recordings => 10
      subject.resume_recording

      subject.should be_recording
    end

    context 'when we have no credits' do
      it 'is always false' do
        subject.account.stub :enough_credits? => false
        subject.stub :scheduled_recordings => 10
        subject.resume_recording

        subject.should_not be_recording
      end
    end

    context 'when developer has paused recordings' do
      it 'is always false regardless credits or remaining recordings needed' do
        subject.account.stub :enough_credits? => true
        subject.stub :scheduled_recordings => 10
        subject.pause_recording

        subject.should_not be_recording
      end
    end

    context 'when we have credits and recording is not paused' do
      before do
        subject.account.stub :enough_credits? => true
        subject.resume_recording
      end

      it 'is true if we need more recordings' do
        subject.stub :scheduled_recordings => 10

        subject.should be_recording
      end

      it 'is false if we do not need more recordings' do
        subject.stub :scheduled_recordings => 0

        subject.should_not be_recording
      end
    end

  end

  context 'when controlling the master switch of recording or not' do
    specify '#pause_recording pauses recording state' do
      subject.pause_recording

      subject.should be_recording_paused
    end

    specify '#resume_recording resumes recording state to recording' do
      subject.resume_recording

      subject.should_not be_recording_paused
    end
  end

  context 'when checking how many more recordings to do' do
    describe '#scheduled_recordings' do
      it 'is a number' do
        subject.scheduled_recordings.should be_an_instance_of Fixnum
      end

      it 'cannot be negative' do
        (subject.scheduled_recordings+10).times { subject.complete_recording }

        subject.scheduled_recordings.should == 0
      end
    end

    describe '#schedule_recordings' do
      it 'saves the time of the scheduling' do
        subject.schedule_recordings 10
        subject.settings[:scheduled_at].should_not be_nil
      end

      it 'sets the total scheduled recordings' do
        expect { subject.schedule_recordings 1000 }.
          to change { subject.scheduled_recordings }.to 1000
      end
    end

    describe '#complete_recording' do
      it 'decrements recordings to be collected' do
        expect { subject.complete_recording }.
          to change { subject.scheduled_recordings }.by(-1)
      end

      it 'uses credit from associated account' do
        subject.account.should_receive(:use_credits).with(1)

        subject.complete_recording
      end

      it 'notifies users' do
        subject.should_receive :notify_users

        subject.complete_recording
      end

      context 'when we get more recordings than expected' do
        before { subject.stub :scheduled_recordings => 0 }

        it 'is no op for the case we have received more recordings than expected' do
          subject.account.should_not_receive :use_credits

          subject.complete_recording
        end

        it 'handles extra recordings' do
          subject.should_receive :handle_extra_recordings

          subject.complete_recording
        end
      end
    end
  end

  describe '#handle_extra_recordings' do
    it 'reset scheduled recordings back to 0' do
      subject.should_receive(:schedule_recordings).with(0)

      subject.handle_extra_recordings
    end
  end

  describe '#uploading_on_wifi_only?' do
    it 'is true if setting says yes' do
      subject.set_uploading_on_wifi_only true

      subject.should be_uploading_on_wifi_only
    end

    it 'is false if setting says no' do
      subject.set_uploading_on_wifi_only false

      subject.should_not be_uploading_on_wifi_only
    end
  end

  describe '#administrator' do
    it 'is also the administrator of the parent account' do
      subject.administrator.should == subject.account.administrator
    end
  end

  describe '#emails' do
    let(:viewers) { [(mock :email => 'def'), (mock :email => 'ghi')] }
    before do
      subject.stub :viewers => viewers
    end

    it 'combines email from viewers' do
      subject.emails.should == ['def', 'ghi']
    end

    it 'returns unique emails' do
      subject.stub :viewers => (viewers << (mock :email => 'def'))
      subject.viewers.should have(3).viewers

      subject.emails.should == ['def', 'ghi']
    end
  end

  describe '#previously_notified?' do
    before { subject.schedule_recordings 1 }
    it 'is false if we have just finished all recordings' do
      subject.should_not be_previously_notified
    end

    it 'is true if we have notified users' do
      subject.scheduled_recordings.times { subject.complete_recording }

      subject.should be_previously_notified
    end
  end

  describe '#ready_to_notify?' do
    context 'when there are still scheduled recordings' do
      before { subject.stub :scheduled_recordings => 10 }
      it 'is always false' do
        subject.should_not be_ready_to_notify
      end
    end

    context 'when there is no more scheduled recordings' do
      before { subject.stub :scheduled_recordings => 0 }
      it 'is true if we have not notified our users' do
        subject.stub :previously_notified? => false

        subject.should be_ready_to_notify
      end

      it 'is false if we have' do
        subject.stub :previously_notified? => true

        subject.should_not be_ready_to_notify
      end
    end
  end

  describe '#notify_users' do
    context 'when it is time to notify' do
      it 'enqueues email notification' do
        subject.stub :ready_to_notify? => true
        Resque.should_receive(:enqueue).once.
          with(AppRecordingCompletion, subject.id)

        subject.notify_users
      end

      it 'only sends one email' do
        # TODO: not sure why Account#email_new_signup will trigger the
        #       expectation below.
        subject

        Resque.should_receive(:enqueue).once.
          with(AppRecordingCompletion, subject.id)

        # TODO: not happy w/ how this is tested.
        #       sign of too much coupling?
        subject.schedule_recordings 1
        subject.scheduled_recordings.times { subject.complete_recording }
        subject.complete_recording
      end
    end

    context 'when it is not time to notify' do
      before { subject.stub :ready_to_notify? => false }

      it 'does not enqueue email notification' do
        Resque.should_not_receive :enqueue

        subject.notify_users
      end
    end
  end

  describe "last viewed time" do
    let(:viewer) { FactoryGirl.create(:viewer) }

    it "should be nil when never viewed" do
      subject.last_viewed_at_by_user(viewer).should be_nil
    end

    it "should throw exception if no view permission" do
      lambda { subject.log_view(viewer) }.should raise_error("Invalid permission")
    end

    describe "has permission" do
      before(:each) do
        subject.viewers << viewer
      end

      it "should return last viewed when viewed at least once" do
        start_time = Time.now
        subject.log_view(viewer)
        subject.last_viewed_at_by_user(viewer).should >= start_time
      end

      it "should return the lastest viewed time" do
        permission = Permission.find_or_create_by_app_id_and_viewer_id(subject.id, viewer.id)
        permission.last_viewed_at = 10.days.ago
        permission.save!
        subject.log_view(viewer)
        subject.last_viewed_at_by_user(viewer).should >= 10.days.ago
      end
    end
  end
end
