require 'spec_helper'

describe App do

  subject { FactoryGirl.create :app }

  describe "on creation" do
    its(:scheduler) { should be_recording }
    its(:token) { should_not be_empty }
    it "should add admin as viewer" do
      subject.viewers.should include(subject.account.administrator)
    end
  end

  describe '#generate_token' do
    it 'is a combination of random keys and own id' do
      SecureRandom.should_receive(:hex).at_least(1).and_return('FFFF')

      subject.token.should == "FFFF#{subject.id}"
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
