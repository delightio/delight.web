require 'spec_helper'

describe S3Storage do
  subject { S3Storage.new "blah.mp4" }

  describe '#bucket_name' do
    let(:bucket_name) { 'bucket' }
    it 'reads from ENV' do
      ENV['S3_UPLOAD_BUCKET'] = bucket_name

      subject.bucket_name.should == bucket_name
    end
  end

  describe '#presigned_bucket' do
    it 'generates presigned bucket'
    it 'creates bucket if it did not exit'
  end

  context 'when generating presigned uris' do
    describe '#presigned_write_uri' do
      xit 'returns url for writing' do
        subject.presigned_object.should_receive(:url_for).with(:write)

        puts subject.presigned_write_uri
      end
    end

    describe '#presigned_read_uri' do
      xit 'returns url for reading' do
        subject.presigned_object.should_receive(:url_for).with(:read)

        puts subject.presigned_read_uri
      end
    end
  end
end