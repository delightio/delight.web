require 'spec_helper'

describe VideoUploader do
  let(:session_id) { 10 }
  subject { VideoUploader.new session_id }
  its(:filename) { should match /.mp4/ }

  context 'when generating presigned uris' do
    let(:object) { mock }
    before { subject.stub :object => object }

    describe '#presigned_write_uri' do
      it 'asks for read permission' do
        object.should_receive(:url_for).with(:write)

        subject.presigned_write_uri
      end
    end

    describe '#presigned_read_uri' do
      it 'asks for read permission' do
        object.should_receive(:url_for).with(:read)

        subject.presigned_read_uri
      end
    end
  end
end