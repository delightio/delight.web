require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }

  describe '#create' do
    it 'creates presigned URI for uploading recording' do
      VideoUploader.any_instance.should_receive(:presigned_uri).
        and_return("blah")
      subject.upload_uris.should have_key :screen
    end
  end

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

end
