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

  describe "caching" do
    before(:each) do
      @s3_new_count = 0
      AWS::S3.any_instance.stub(:new) do |arg|
        @s3_new_count += 1
      end
    end

#    it "should recreate presigned bucket when renew interval is reached" do
#      S3Storage::SESSION_RENEW_INTERVAL = 0.second
#      subject.presigned_bucket
#      @s3_new_count.should == 1
#      subject.presigned_bucket
#      @s3_new_count.should == 2
#    end
#
#    it "should cache calls to S3#new" do
#      S3Storage::SESSION_RENEW_INTERVAL = 0.second
#      subject.presigned_bucket
#      @s3_new_count.should == 1
#      subject.presigned_bucket
#      @s3_new_count.should == 2
#      S3Storage::SESSION_RENEW_INTERVAL = 50.minutes
#      subject.presigned_bucket
#      @s3_new_count.should == 2
#    end
  end
end
