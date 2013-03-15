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
    let(:original) { File.join Rails.root, subject.filename }
    let(:local_directory) { '/tmp' }
    let(:downloaded) { File.join local_directory, subject.filename }

    it 'downloads associated filename to local directory' do
      subject.download local_directory
      FileUtils.compare_file(original, downloaded).should == true
    end

    it 'returns a File object' do
      subject.download(local_directory).should be_an_instance_of File
    end
  end

  describe '#upload' do
    subject { S3Storage.new 'Procfile', 'delight_rspec' }
    let(:local_file) { File.new File.join Rails.root, subject.filename }

    it 'uploads given local file to S3' do
      presigned_object = mock
      subject.stub :presigned_object => presigned_object
      presigned_object.should_receive(:write).with(local_file.read)

      subject.upload local_file
    end
  end

  describe '#exists?' do
    it 'is true if it exists with a non zero size' do
      subject.stub :presigned_object => (stub :exists? => true)
      subject.presigned_object.stub :content_length => 10

      subject.should be_exists
    end

    it 'is false if it does not exist with zero size' do
      subject.stub :presigned_object => (stub :exists? => true)
      subject.presigned_object.stub :content_length => 0

      subject.should_not be_exists
    end

    it 'is false if it does not exist' do
      subject.stub :presigned_object => (stub :exists? => false)

      subject.should_not be_exists
    end
  end
end