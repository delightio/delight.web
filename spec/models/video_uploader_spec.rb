require 'spec_helper'

describe VideoUploader do
  let(:session_id) { 10 }
  subject { VideoUploader.new session_id }

  describe '#presigned_uri' do
    it 'consists of bucket name and has .mp4 extension' do
      subject.presigned_uri.to_s.should match /.mp4/
    end
  end
end