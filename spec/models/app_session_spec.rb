require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }

  describe '.recorded' do
    it 'returns all recorded sessions which are completed and we had expected more than 1 tracks'
  end

  describe '.completed' do
    it 'returns completed sessions which we have received the expected number of tracks'
  end

  describe '#completed?' do
    it 'is true after we have received the expected number of tracks' do
      subject.stub :expected_track_count => 0
      subject.stub :tracks => []

      subject.should be_completed
    end
  end

  describe '#expected_presentation_track_count' do
    it 'is 1 if we are to record' do
      subject.stub :recording? => true

      subject.expected_presentation_track_count.should == 1
    end

    it 'is 0 if we are not to record' do
      subject.stub :recording? => false

      subject.expected_presentation_track_count.should == 0
    end
  end

  describe '#ready_for_processing?' do
    before do
      subject.stub :expected_presentation_track_count => 1
      subject.stub :expected_track_count => 3
    end

    it 'is true when we have received the expected number of tracks (- presentation track)' do
      subject.stub :tracks => [mock, mock]

      subject.should be_ready_for_processing
    end

    it 'is false otherwise' do
      subject.stub :track => [mock]

      subject.should_not be_ready_for_processing
    end
  end

  describe '#recorded?' do
    it 'is true after session is completed and we had expected more than 1 tracks' do
      subject.stub :completed? => true
      subject.stub :expected_track_count => 2

      subject.should be_recorded
    end
  end

  describe '#recording?' do
    it 'reads from its associated app' do
      subject.app.should_receive :recording?

      subject.recording?
    end

    it 'is always false when version is less than 2' do
      subject.delight_version = '1.0'
      subject.app.should_not_receive :recording?

      subject.should_not be_recording
    end
  end

  describe '#expected_track_count' do
    subject { FactoryGirl.create :non_recording_app_session }
    it 'is 0 when not recording' do
      subject.expected_track_count.should == 0
    end
  end

  describe '#uploading_on_wifi_only?' do
    it 'reads from its associated app' do
      subject.app.should_receive :uploading_on_wifi_only?

      subject.uploading_on_wifi_only?
    end
  end

  describe 'favorite_of' do
    let(:app_session1) { FactoryGirl.create(:app_session) }
    let(:app_session2) { FactoryGirl.create(:app_session) }
    let(:app_session3) { FactoryGirl.create(:app_session) }
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      user.favorite_app_sessions << app_session1
      user.favorite_app_sessions << app_session3
    end

    it "should get favorite of user" do
      as = AppSession.favorite_of(user).all
      as.should include(app_session1)
      as.should include(app_session3)
      as.should_not include(app_session2)
    end
  end

  describe 'date_between' do
    let(:start_date) { 10.days.ago }
    let(:end_date) { 1.day.ago }
    let(:session_before) { FactoryGirl.create :app_session, :created_at => 11.days.ago }
    let(:session_start) { FactoryGirl.create :app_session, :created_at => start_date }
    let(:session_between) { FactoryGirl.create :app_session, :created_at => 3.days.ago }
    let(:session_end) { FactoryGirl.create :app_session, :created_at => end_date }
    let(:session_after) { FactoryGirl.create :app_session, :created_at => 1.hour.ago }

    before(:each) do
      # clear all items and load only the 5 below
      AppSession.delete_all
      session_before
      session_start
      session_between
      session_end
      session_after
    end

    it "should return all sessions with created_at set at nil" do
      sessions = AppSession.date_between(nil, nil).all
      sessions.should have(5).items
    end

    it "should include only sessions within min and max" do
      sessions = AppSession.date_between(start_date, end_date).all
      sessions.should include(session_start)
      sessions.should include(session_between)
      sessions.should include(session_end)
    end
  end

  describe 'duration_between' do
    let(:start_duration) { 1 }
    let(:end_duration) { 10 }
    let(:duration_before) { FactoryGirl.create :app_session, :duration => 0.5 }
    let(:duration_start) { FactoryGirl.create :app_session, :duration => start_duration }
    let(:duration_between) { FactoryGirl.create :app_session, :duration => 5 }
    let(:duration_end) { FactoryGirl.create :app_session, :duration => end_duration }
    let(:duration_after) { FactoryGirl.create :app_session, :duration => 12 }

    before(:each) do
      # clear all items and load only the 5 below
      AppSession.delete_all
      duration_before
      duration_start
      duration_between
      duration_end
      duration_after
    end

    it "should return all sessions with duration set at nil" do
      sessions = AppSession.duration_between(nil, nil).all
      sessions.should have(5).items
    end

    it "should include only sessions within min and max" do
      sessions = AppSession.duration_between(start_duration, end_duration).all
      sessions.should include(duration_start)
      sessions.should include(duration_between)
      sessions.should include(duration_end)
    end
  end

  describe '#complete_upload' do
    context 'when sesison is recorded' do
      before { subject.stub :recorded? => true }

      it 'tells associated app to update recording accounting' do
        subject.app.should_receive :complete_recording

        subject.complete_upload mock
      end
    end

    context 'when session is not completed' do
      before { subject.stub :recorded? => false }

      it 'does not update recording accounting' do
        subject.app.should_not_receive :complete_recording

        subject.complete_upload mock
      end
    end

    context 'when ready for processing' do
      it 'enqueues processing' do
        subject.stub :ready_for_processing? => true
        subject.should_receive :enqueue_processing

        subject.complete_upload mock
      end
    end

    context 'when not ready for processing' do
      it 'does not enqueue processing' do
        subject.stub :ready_for_processing? => false
        subject.should_not_receive :enqueue_processing

        subject.complete_upload mock
      end
    end
  end

  describe '#enqueue_processing' do
    it 'enqueues video processing' do
      VideoProcessing.should_receive(:enqueue).with(subject.id)

      subject.enqueue_processing
    end
  end

  context 'named_track' do
    [:screen_track, :touch_track, :front_track].each do |named_track|
      specify "#{named_track} returns associated #{named_track}" do
        track = FactoryGirl.create named_track, app_session: subject

        subject.send(named_track).should == track
      end
    end
  end

  describe '#working_directory' do
    before do
      @expected_dir = File.join ENV['WORKING_DIRECTORY'], subject.id.to_s
      Dir.stub(:exists?).with(@expected_dir).and_return(true)
    end

    it 'is based on id and ENV variable' do
      subject.working_directory.should == @expected_dir
    end

    it 'creates such direction if it does not exists' do
      Dir.stub(:exists?).with(@expected_dir).and_return(false)
      FileUtils.should_receive(:mkdir_p).with(@expected_dir)

      subject.working_directory
    end
  end

  describe '#generate_upload_uris' do
    it 'is called after object creation' do
      AppSession.any_instance.
        should_receive(:generate_upload_uris).once

      subject
    end

    it 'only generates upload uris if recording' do
      subject.stub :recording? => false
      subject.send :generate_upload_uris

      subject.upload_uris.should == Hash.new
    end

    it 'expects a screen and a touch track' do
      subject.stub :recording? => true
      ScreenTrack.should_receive(:new).and_return(mock.as_null_object)
      TouchTrack.should_receive(:new).and_return(mock.as_null_object)

      subject.send :generate_upload_uris
      subject.expected_track_count.should == 2
      subject.upload_uris.should have_key :screen_track
      subject.upload_uris.should have_key :touch_track
    end
  end

  describe 'association' do
    let(:user) { FactoryGirl.create(:user) }
    let(:app_session) { FactoryGirl.create(:app_session) }

    it "should assign favorite user correctly" do
      app_session.favorite_users.should == []
      app_session.favorite_users << user
      app_session.favorite_users.should == [user]
    end
  end
end
