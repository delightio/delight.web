require 'spec_helper'

describe PresentationTrack do
  subject { PresentationTrack.new app_session: app_session }
  let(:app_session) { FactoryGirl.create :app_session }
  let(:local_file) { File.new File.join Rails.root, '.gitignore' }

  describe '#after_create' do
    let(:app_session) { FactoryGirl.create :app_session }
    subject { FactoryGirl.create(:presentation_track, app_session: app_session) }

    context 'when the track is complete' do
      before { PresentationTrack.any_instance.stub :complete? => true }

      it 'updates associated app about completion' do
        app_session.should_receive :complete

        subject
      end
    end

    context 'when the track is not complete' do
      before { PresentationTrack.any_instance.stub :complete? => false }

      it 'does not update associated app' do
        app_session.should_not_receive :complete

        subject
      end
    end
  end

  describe '#upload' do
    it 'uploads given file to cloud' do
      subject.storage.should_receive(:upload).with(local_file)

      subject.upload local_file
    end
  end

  describe '#thumbnail' do
    it 'creates a Thumbnail object with specific name' do
      thumbnail = "#{subject.filename}.thumbnail.jpg"
      Thumbnail.should_receive(:new).with(thumbnail)

      subject.thumbnail
    end
  end

  describe '#exists?' do
    it 'is true if it exists on remote storage' do
      subject.storage.stub :exists? => true

      subject.should be_exists
    end
  end

  describe '#complete?' do
    it 'is true when both the file and thumbnail exist on remote storage' do
      subject.stub :exists? => true
      subject.thumbnail.stub :exists? => true

      subject.should be_complete
    end

    it 'is false if track does not exist on remote storage' do
      subject.stub :exists? => false

      subject.should_not be_complete
    end

    it 'is false if thumbnail does not exist on remote storage' do
      subject.thumbnail.stub :exits? => false

      subject.should_not be_complete
    end
  end
end