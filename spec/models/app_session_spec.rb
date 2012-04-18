require 'spec_helper'

describe AppSession do
  subject { FactoryGirl.create :app_session }
  it { should_not be_recording }

  describe '#generate_upload_uris' do
    it 'is called after object creation' do
      AppSession.any_instance.
        should_receive(:generate_upload_uris).once

      subject
    end

    it 'only generates upload uris if recording' do
      subject.stub :recording? => false

      expect { subject.generate_upload_uris }.to
        change { subject.upload_uris }.to({})
    end

    let(:presigned_uri) { 'presigned' }
    it 'uses VideoUploader to generate the presigned URI' do
      subject.stub :recording? => true
      VideoUploader.any_instance.stub :presigned_uri => presigned_uri

      subject.generate_upload_uris
      subject.upload_uris[:screen].should == presigned_uri
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