require 'spec_helper'

describe App do

  subject { FactoryGirl.create :app }
  its(:token) { should_not be_empty }
  it { should_not be_recording }

  describe '#generate_token' do
    it 'is a combination of random keys and own id' do
      SecureRandom.should_receive(:hex).at_least(1).and_return('FFFF')

      subject.generate_token.should == "FFFF#{subject.id}"
    end
  end

  describe '#recording?' do
    context 'when we have no credits' do
      it 'is always false' do
        subject.account.stub :remaining_credits => 0
        subject.stub :remaining_recordings => 10
        subject.resume_recording

        subject.should_not be_recording
      end
    end

    context 'when developer has paused recordings' do
      it 'is always false regardless credits or remaining recordings needed' do
        subject.account.stub :remaining_credits => 20
        subject.stub :remaining_recordings => 10
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
        subject.stub :remaining_recordings => 10

        subject.should be_recording
      end

      it 'is false if we do not need more recordings' do
        subject.stub :remaining_recordings => 0

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
    describe '#remaining_recordings' do
      it 'is a number' do
        subject.remaining_recordings.should be_an_instance_of Fixnum
      end

      it 'can be negative' do
        subject.use_recordings subject.remaining_recordings + 20

        subject.remaining_recordings.should < 0
      end
    end

    let(:recordings_change) { 30 }
    describe '#add_recordings' do
      it 'increments recordings to be collected' do
        expect { subject.add_recordings recordings_change }.
          to change { subject.remaining_recordings }.by recordings_change
      end
    end

    describe '#use_recordings' do
      it 'decrements recordings to be collected' do
        expect { subject.use_recordings recordings_change }.
          to change { subject.remaining_recordings }.by(-1 * recordings_change)
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