require 'spec_helper'

describe Video do
  subject { FactoryGirl.create :video }

  it 'updates associated app about new uploads' do
    AppSession.any_instance.should_receive :complete_upload

    subject
  end

  describe '#presigned_read_uri' do
    it 'gets presigned_read_uri fro VideoUploader' do
      VideoUploader.any_instance.should_receive :presigned_read_uri

      subject.presigned_read_uri
    end
  end
end