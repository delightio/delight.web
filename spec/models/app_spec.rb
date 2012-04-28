require 'spec_helper'

describe App do

  subject { FactoryGirl.create :app }
  it { should be_recording } # We always schedule recordings on creation
  its(:token) { should_not be_empty }

  describe '#generate_token' do
    it 'is a combination of random keys and own id' do
      SecureRandom.should_receive(:hex).at_least(1).and_return('FFFF')

      subject.token.should == "FFFF#{subject.id}"
    end
  end

  describe "creation" do
    it "should have some scheduled recording" do
      subject.scheduled_recordings.should == Account::FreeCredits
    end
  end

  describe '#recording?' do
    specify 'credits have no effect' do
      subject.stub :remaining_credits => 0
      subject.stub :scheduled_recordings => 10
      subject.resume_recording

      subject.should be_recording
    end

    # context 'when we have no credits' do
    #   it 'd'
    #   it 'is always false' do
    #     subject.account.stub :remaining_credits => 0
    #     subject.stub :scheduled_recordings => 10
    #     subject.resume_recording

    #     subject.should_not be_recording
    #   end
    # end

    context 'when developer has paused recordings' do
      it 'is always false regardless credits or remaining recordings needed' do
        subject.account.stub :remaining_credits => 20
        subject.stub :scheduled_recordings => 10
        subject.pause_recording

        subject.should_not be_recording
      end
    end

    context 'when we have credits and recording is not paused' do
      before do
        subject.account.stub :remaining_credits => 200
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

      it 'can be negative' do
        (subject.scheduled_recordings+10).times { subject.complete_recording }

        subject.scheduled_recordings.should < 0
      end
    end

    describe '#schedule_recordings' do
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
end
