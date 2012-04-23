require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }
  it { should_not be_recording }

  describe '#recording?' do
    it 'reads from its associated app' do
      subject.app.should_receive :recording?

      subject.recording?
    end
  end

  describe '#uploading_on_wifi_only?' do
    it 'reads from its associated app' do
      subject.app.should_receive :uploading_on_wifi_only?

      subject.uploading_on_wifi_only?
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
    it 'tells associated app to update recording accounting' do
      subject.app.should_receive :complete_recording

      subject.complete_upload mock
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

    let(:presigned_write_uri) { 'presigned' }
    it 'uses VideoUploader to generate the presigned URI' do
      subject.stub :recording? => true
      VideoUploader.any_instance.stub :presigned_write_uri => presigned_write_uri

      subject.send :generate_upload_uris
      subject.upload_uris[:screen].should == presigned_write_uri
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
