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
    it 'asks scheduler' do
      subject.scheduler.should_receive :recording?

      subject.recording?
    end
  end

  context 'when checking how many more recordings to do' do
    describe '#scheduled_recordings' do
      it 'is a number' do
        subject.scheduled_recordings.should be_an_instance_of Fixnum
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
          # because scheduled_recordings does not change.
          # it is the recorded that change. Maybe we should have
          # a Scheduler#reminaing
      end

      let(:cost) { 10 }
      it 'uses credit from associated account' do
        subject.account.should_receive(:use_credits).with(cost)

        subject.complete_recording cost
      end

      context 'when we get more recordings than expected' do
        before { subject.scheduler.stub :completed? => true }

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

  describe '#administrator' do
    it 'is also the administrator of the parent account' do
      subject.administrator.should == subject.account.administrator
    end
  end

  describe '#administered_by?' do
    let(:viewer) { mock }
    let(:admin) { mock }
    before do
      subject.stub :viewers => [viewer]
      subject.stub :administrator => admin
    end

    it 'includes administrator and viewers' do
      subject.should be_administered_by(admin)
      subject.should be_administered_by(viewer)
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
