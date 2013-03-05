require 'spec_helper'

describe Track do
  describe '#after_create' do
    let(:app_session) { FactoryGirl.create :app_session }
    subject { FactoryGirl.create(:track, app_session: app_session) }

    it 'updates associated app about new uploads' do
      app_session.should_receive :track_uploaded

      subject
    end
  end

  describe '#file_extension' do
    it 'needs to be defined in sub class' do
      expect { subject.file_extension }.
        to raise_error
    end
  end

  let(:app_session) { FactoryGirl.create :app_session }
  subject { FactoryGirl.create(:track, app_session: app_session).tap {
              |t| t.stub :filename => 'blah.blah' } }

  describe '#storage' do
    it 'uses S3' do
      S3Storage.should_receive(:new).with(subject.filename)

      subject.storage
    end
  end

  describe '#presigned_write_uri' do
    it 'calls storage#presigned_write_uri' do
      subject.storage.should_receive :presigned_write_uri

      subject.presigned_write_uri
    end
  end

  describe '#presigned_read_uri' do
    it 'calls storage#presigned_read_uri' do
      subject.storage.should_receive :presigned_read_uri

      subject.presigned_read_uri
    end
  end

  describe '#download' do
    before do
      local_filename = File.join Rails.root, '.gitignore'
      subject.storage.should_receive(:download).
        with(subject.app_session.working_directory).
        and_return(File.new local_filename)
    end

    it 'downloads online version to the working directory' do
      subject.download
    end

    it 'returns a File object' do
      subject.download.should be_an_instance_of File
    end
  end

  describe '#short_type' do
    context 'when there is a sub type' do
      before { subject.stub :type => "Track::PresentationTrack" }
      it 'includes sub type' do
        subject.short_type.should == "presentationtrack"
      end
    end

    context 'when there is no sub type' do
      before { subject.stub :type => nil }
      it 'does not include a sub type' do
        subject.short_type.should be_empty
      end
    end
  end

  describe '#filename' do
    let(:app_session) { FactoryGirl.create :app_session }
    subject { FactoryGirl.create(:track, app_session: app_session).tap do |s|
                s.stub :short_type => "presentationtrack"
                s.stub :file_extension => "mp4"
              end
            }

    it 'contains app session id, short type and file extension' do
      subject.filename.should == "session_#{app_session.id}_presentationtrack.mp4"
    end
  end

  describe '#json_url' do
    it 'returns endpoint for accessing the json' do
      subject.json_url.should == "http://#{Rails.configuration.host}/tracks/#{subject.id}.json"
    end
  end
end