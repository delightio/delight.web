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

  subject { t = Track.new.tap{ |t| t.stub :filename => 'fkjdklfj'} }
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

end