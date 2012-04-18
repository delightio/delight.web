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

  describe '#recording?' do
    it 'reads from its associated app' do
      subject.app.should_receive :recording?

      subject.recording?
    end
  end

  describe '#uploading_on_wifi_only?' do
    it 'reads from its associated app' do
      subject.app.should_receive :uploading_on_wifi_only?

      subject.uploading_on_wifi_only?
    end
  end
end