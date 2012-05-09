require 'spec_helper'

describe S3Storage do
  subject { S3Storage.new "blah.mp4" }
  its(:bucket_name) { should == ENV['S3_UPLOAD_BUCKET'] }

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

  describe '#download' do
    subject { S3Storage.new 'Procfile', 'delight_rspec' }
    let(:local_directory) { '/tmp' }
    let(:downloaded) { File.join local_directory, subject.filename }
    let(:original) { File.join Rails.root, subject.filename }

    it 'downloads associated filename to local directory' do
      subject.download local_directory
      FileUtils.compare_file(original, downloaded).should == true
    end
  end
end