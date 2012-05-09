require 'spec_helper'

describe PresentationTrack do
  subject { PresentationTrack.new app_session: app_session }
  let(:app_session) { FactoryGirl.create :app_session }
  let(:local_file) { File.new File.join Rails.root, '.gitignore' }

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
end