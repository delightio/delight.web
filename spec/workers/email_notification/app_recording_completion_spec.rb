require 'spec_helper'

describe AppRecordingCompletion do
  subject { AppRecordingCompletion }

  describe '#perform' do
    let(:app) { FactoryGirl.create :app }
    it 'sends email to everyone' do
      subject.should_receive(:send_text).with(
        app.emails, instance_of(String), instance_of(String)).once

      subject.perform app.id
    end
  end
end