require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }

  describe '.recorded' do
    it 'returns all recorded sessions which are completed and we had expected more than 1 tracks'
  end

  describe '.completed' do
    it 'returns completed sessions which we have received the expected number of tracks'
  end

  describe '#events_with_time' do
    let(:event) { stub :name => "event_name" }
    let(:event_info) { stub :event => event, :time => 10 }
    before do
      subject.stub :event_infos => [event_info]
    end

    it 'retuns array of hash with name and time' do
      subject.events_with_time.should == [{name: "event_name", time: 10.0}]
    end
  end

  describe '#private_framework?' do
    it 'is true if delight_version number contains Private' do
      subject.stub :delight_version => '3.4.Private'

      subject.should be_private_framework
    end

    it 'is false if delight_version does not contain private' do
      subject.stub :delight_version => '2.4'

      subject.should_not be_private_framework
    end
  end

  describe '#completed?' do
    it 'is true after we have received the expected number of tracks' do
      subject.stub :expected_track_count => 0
      subject.stub :tracks => []

      subject.should be_completed
    end
  end

  describe '#ready_for_processing?' do
    before do
      subject.stub :processed_tracks => [mock, mock]
      subject.stub :expected_track_count => 4
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
    let(:recording_scheduler) { FactoryGirl.create :scheduler }
    before { subject.stub scheduler: recording_scheduler }

    it 'asks scheduler if it should record' do
      recording_scheduler.should_receive(:recording?).and_return(true)
      subject.stub scheduler: recording_scheduler

      subject.should be_recording
    end

    it 'is always false when version is less than 2' do
      subject.delight_version = '1.0'
      recording_scheduler.should_not_receive :recording?

      subject.should_not be_recording
    end

    # https://github.com/delightio/delight.ios/issues/12
    context 'when the app is SimplePrint' do
      before do
        subject.app.stub :id => 653
        subject.stub :app_id => 653
      end

      it 'is true if iOS is not 6.x' do
        subject.stub :device_os_version => "5.0"

        subject.should be_recording
      end

      it 'is true if iOS is above 6 and delight version is 2.3.2' do
        subject.stub :device_os_version => "6.0.1"
        subject.stub :delight_version => "2.3.2.Private"

        subject.should be_recording
      end

      it 'is false if iOS is above 6 and delight version is not 2.3.2' do
        subject.stub :device_os_version => "6.0.1"
        subject.stub :delight_version => "2.3.1"

        subject.should_not be_recording
      end

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

  describe '#maximum_frame_rate' do
    context 'app session from private framework' do
      before { subject.stub :private_framework? => true }

      its(:maximum_frame_rate) { should == 20 }
    end

    context 'app session from non private framework' do
      before { subject.stub :private_framework? => false }

      its(:maximum_frame_rate) { should == 10 }
    end
  end

  describe '#scale_factor' do
    context 'when device is iPad 3' do
      before { subject.stub :device_hw_version => 'iPad3,3' }

      its(:scale_factor) { should == 0.25 }
    end

    context 'when device is not iPad 3' do
      before { subject.stub :device_hw_version => 'iPhone4,1' }

      its(:scale_factor) { should == 0.5 }
    end
  end

  describe '#average_bit_rate' do
    it 'generates 1 MB of video per one minute of recording' do
      bits_per_minute = subject.average_bit_rate * 60
      bits_per_minute.should be_within(10*1024).of(8*1024*1024)
    end

    context 'when recording from private frame' do
      before { subject.stub :private_framework? => true }
      it 'generates 500 kpbs video' do
        subject.average_bit_rate.should == 500000
      end
    end
  end

  describe '#maximum_key_frame_interval' do
    it 'is one frame every 10 minutes of recording' do
      n_frames_in_10_minutes = subject.maximum_frame_rate * 10.minutes
      subject.maximum_key_frame_interval.should == n_frames_in_10_minutes
    end
  end

  describe '#maximum_duration' do
    its(:maximum_duration) { should == 1.hours }
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

  describe "#by_funnel" do
    it "shouldn't by_funnel to filter if argument is nil or blank" do
      AppSession.by_events([]).should include(subject)
    end

    it "should filter app sessions by funnel" do
      app = FactoryGirl.create :app

      event1 = app.events.find_or_create_by_name!("item-selected")
      event2 = app.events.find_or_create_by_name!("item-purchased")
      event3 = app.events.find_or_create_by_name!("item-not-selected")

      session1 = FactoryGirl.create :app_session_with_event_track
      session2 = FactoryGirl.create :app_session_with_event_track
      session3 = FactoryGirl.create :app_session_with_event_track

      session1.events << [event1]
      session2.events << [event1, event2]
      session3.events << [event1, event3]

      funnel1 = app.funnels.create!(name: "selected-funnel", events: [event1])
      funnel2 = app.funnels.create!(name: "purchased-funnel", events: [event1, event2])
      funnel3 = app.funnels.create!(name: "unpurchased-funnel", events: [event1, event3])

      sessions = AppSession.by_funnel(funnel1)
      sessions.sort.should == [session1, session2, session3]

      sessions = AppSession.by_funnel(funnel2)
      sessions.sort.should == [session2]

      sessions = AppSession.by_funnel(funnel3)
      sessions.sort.should == [session3]
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

  describe "has_property" do
    let(:session123) { FactoryGirl.create :app_session, :duration => 0.5 }
    let(:session123_2) { FactoryGirl.create :app_session, :duration => 0.5 }
    let(:another_session) { FactoryGirl.create :app_session, :duration => 0.5 }

    before(:each) do
      AppSession.delete_all
      session123.update_properties :app_user_id  => 123
      session123_2.update_properties :app_user_id  => 123, :some_key => 'somevalue'
      another_session
    end

    it "should return sessions with property that match" do
      sessions = AppSession.has_property('app_user_id', '123')
      #sessions = AppSession.all
      sessions.should have(2).item
      sessions.should include(session123)
      sessions.should include(session123_2)

      sessions = AppSession.has_property('some_key', 'somevalue')
      sessions.should == [session123_2]
    end
  end


  describe '#track_uploaded' do
    context 'when ready for processing' do
      it 'enqueues processing' do
        subject.stub :ready_for_processing? => true
        subject.should_receive :enqueue_processing

        subject.track_uploaded mock
      end
    end

    context 'when not ready for processing' do
      it 'does not enqueue processing' do
        subject.stub :ready_for_processing? => false
        subject.should_not_receive :enqueue_processing

        subject.track_uploaded mock
      end
    end
  end

  describe 'credits' do
    its(:credits) { should == 1 }
  end

  describe '#cost' do
    context 'when the duration is short' do
      let(:short_session) { FactoryGirl.create :app_session, :duration => 5 }

      it 'is 0' do
        short_session.cost.should == 0
      end
    end

    context 'when the duration is longer than minimum' do
      let(:normal_session) { FactoryGirl.create :app_session, :duration => 10 }

      it 'is equal to credits' do
        normal_session.cost.should == normal_session.credits
      end
    end
  end


  describe '#complete' do
    it 'tells associated app to update recording accounting' do
      subject.app.should_receive(:complete_recording).with(subject.cost)

      subject.complete
    end
  end

  describe '#enqueue_processing' do
    it 'enqueues video processing' do
      VideoProcessing.should_receive(:enqueue).with(subject.id)

      subject.enqueue_processing
    end
  end

  context 'named_track' do
    [ :screen_track, :touch_track, :front_track, :orientation_track,
      :event_track, :view_track,
      :presentation_track, :gesture_track ].each do |named_track|
      specify "#{named_track} returns associated #{named_track}" do
        track = FactoryGirl.create named_track, app_session: subject

        subject.send(named_track).should == track
      end
    end

    [ :presentation_track, :gesture_track ].each do |named_track|
      specify "#destroy_#{named_track} does nothing when track is not present" do
        subject.stub named_track.to_sym => nil
        Object.any_instance.should_not_receive(:destroy)

        subject.send "destroy_#{named_track}".to_sym
      end

      let(:track) { mock.as_null_object }
      specify "#destroy_#{named_track} destroy given track" do
        subject.stub named_track.to_sym => track
        track.should_receive(:destroy)

        subject.send "destroy_#{named_track}".to_sym
      end
    end
  end

  describe '#upload_tracks' do
    context 'when delight version is equal or newer than 3.0' do
      before { subject.stub :delight_version => '3.0' }
      it 'contains a screen, touch, orientation, view and event track' do
        subject.upload_tracks.should include :screen_track
        subject.upload_tracks.should include :touch_track
        subject.upload_tracks.should include :orientation_track
        subject.upload_tracks.should include :event_track
        subject.upload_tracks.should include :view_track
      end
    end

    context 'when delight version is older than 2.2' do
      before { subject.stub :delight_version => '2.2.2' }
      it 'contains a screen, touch and orientation track' do
        subject.upload_tracks.should include :screen_track
        subject.upload_tracks.should include :touch_track
        subject.upload_tracks.should include :orientation_track
      end

      it 'does not support event and view tracks' do
        subject.upload_tracks.should_not include :event_track
        subject.upload_tracks.should_not include :view_track
      end
    end
  end

  describe '#processed_tracks' do
    it 'has more than 0 track even if we are not recording' do
      subject.stub :recording? => false

      subject.processed_tracks.should have_at_least(1).track
    end

    it 'contains a presentation and gesture track' do
      subject.processed_tracks.should include :presentation_track
      subject.processed_tracks.should include :gesture_track
    end
  end

  describe '#working_directory' do
    before do
      @expected_dir = File.join ENV['WORKING_DIRECTORY'],
                                subject.class.to_s.tableize, subject.id.to_s
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

  describe '#update_properties' do
    let(:properties) { {level: 10} }

    it 'returns true if there is no error' do
      subject.update_properties(nil).should be_true
    end

    it 'returns true after sucessful update' do
      subject.properties.should_receive(:find_or_create_by_key_and_value).with('level', '10')
      subject.update_properties(properties).should be_true
    end
  end

  describe '#update_metrics' do
    let(:metrics) { { private_view_count: 10 } }

    it 'updates metrics' do
      2.times { subject.update_metrics metrics }

      subject.metrics(:private_view_count).should == 20
    end

    it 'always returns true' do
      subject.update_metrics(metrics).should be_true
      subject.update_metrics(nil).should be_true
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

    it 'generates upload_uris from #upload_tracks' do
      subject.stub :recording? => true
      subject.stub :upload_tracks => [:screen_track]
      ScreenTrack.should_receive(:new).with(app_session_id: subject.id).
        and_return(mock.as_null_object)

      subject.send :generate_upload_uris
      subject.upload_uris.should have_key :screen_track
      subject.upload_uris.should have(1).track
    end

    # TODO: We could verify AmazonCredential.new is only called once but
    #       spec fails when S3Storage tries to generate the actual presigned uri
    xit 'reuses Amazon credential' do
      AmazonCredential.should_receive(:new).once.
        and_return(AmazonCredential.new)
      subject.stub :recording? => true

      subject.send :generate_upload_uris
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
