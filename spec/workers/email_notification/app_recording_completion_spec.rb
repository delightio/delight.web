require 'spec_helper'

describe AppRecordingCompletion do
  subject { AppRecordingCompletion }

  describe '#perform' do
    let(:app) { FactoryGirl.create :app }
    let(:data){ {tos: app.emails,
                 subject: instance_of(String),
                 text: instance_of(String)} }
    it 'sends email to everyone' do
      subject.should_receive(:send_text).with(data).once

      subject.perform app.id
    end
  end
end