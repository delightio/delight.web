require 'spec_helper'

describe 'Track' do
  describe '#after_create' do
    let(:app_session) { FactoryGirl.create :app_session }
    subject { FactoryGirl.create(:track, app_session: app_session) }

    it 'updates associated app about new uploads' do
      app_session.should_receive :complete_upload

      subject
    end
  end

  describe '#file_extension' do
    it 'needs to be defined in sub class' do
      expect { subject.file_extension }.
        to raise_error
    end
  end

  let(:app_session) { FactoryGirl.create :app_session }
  subject { FactoryGirl.create(:track, app_session: app_session).tap {
              |t| t.stub :filename => 'blah.blah' } }

  describe '#storage' do
    it 'uses S3' do
      S3Storage.should_receive(:new).with(subject.filename)

      subject.storage
    end
  end

  describe '#presigned_write_uri' do
    it 'calls storage#presigned_write_uri' do
      subject.storage.should_receive :presigned_write_uri

      subject.presigned_write_uri
    end
  end

  describe '#presigned_read_uri' do
    it 'calls storage#presigned_read_uri' do
      subject.storage.should_receive :presigned_read_uri

      subject.presigned_read_uri
    end
  end

  describe '#local_filename' do
    it 'is the file path at where we will download to' do
      subject.local_filename.should ==
        File.join(subject.app_session.working_directory, subject.filename)
    end
  end

  describe '#download' do
    before do
      subject.stub :local_filename => File.join(Rails.root, '.gitignore')
    end

    it 'downloads online version to the working directory' do
      subject.storage.should_receive(:download).
        with(subject.app_session.working_directory)

      subject.download
    end

    it 'returns a File object' do
      subject.stub :storage => mock.as_null_object

      subject.download.should be_an_instance_of File
    end
  end
end