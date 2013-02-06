require 'spec_helper'

describe S3Storage do
  subject { S3Storage.new "blah.mp4" }
  its(:bucket_name) { should == ENV['S3_UPLOAD_BUCKET'] }

  describe '.session' do
    it 'sets up the policy'
    it 'creates a new federated session'
  end

  describe '#cached_credentials' do
    it 'uses cached value when it can' do
      subject.instance_variable_get(:@credentials).stub :expired? => false
      subject.instance_variable_get(:@credentials).should_receive :get
      AWS::STS::Policy.should_not_receive :new

      subject.cached_credentials
    end

    it 'cache newly obtained credentials' do
      subject.instance_variable_get(:@credentials).stub :expired? => true
      subject.instance_variable_get(:@credentials).should_receive :set
      subject.class.should_receive(:session).and_return(mock.as_null_object)

      subject.cached_credentials
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

describe CachedHash do
  subject { CachedHash.new key, ttl}
  let(:key) { "a key" }
  let(:ttl) { 10 }
  let(:content) { {a: 1, b: 2} }

  context 'when given key has not expired' do
    before do
      existing = CachedHash.new key, ttl
      existing.set content
    end

    it 'respects remaining ttl' do
      subject = CachedHash.new key, 10*ttl

      subject.should_not be_expired
      subject.ttl.should <= ttl
    end
  end

  describe '#expired?' do
    it 'is true when key does not exist' do
      subject.should be_expired
    end

    it 'is false if TTL is larger than given input' do
      subject.stub :ttl => 10

      subject.should_not be_expired
    end
  end

  describe '#set' do
    it 'sets values to key' do
      REDIS.should_receive(:hmset).with(key, :blah, 123)

      subject.set blah: 123
    end

    it 'sets an expirary time' do
      REDIS.should_receive(:expire).with(key, ttl)

      subject.set blah:123
    end

    it 'returns values set' do
      subject.set(blah:123).should == { "blah" => "123" }
    end
  end

  describe '#get' do
    it 'reads from Redis' do
      REDIS.should_receive(:hgetall).with(key)
      subject.get
    end
  end
end
