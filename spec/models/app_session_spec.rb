require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }

  describe '#create' do
    it 'creates presigned URI for uploading recording' do
      VideoUploader.any_instance.should_receive(:presigned_uri).
        and_return("blah")
      subject.upload_uris.should have_key :screen
    end
  end
end