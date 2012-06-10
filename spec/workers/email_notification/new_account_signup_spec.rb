require 'spec_helper'

describe NewAccountSignup do
  subject { NewAccountSignup }

  describe '#perform' do
    let(:email) { mock }
    let(:data){ {to: email,
                 from: instance_of(String),
                 bcc: instance_of(String),
                 subject: instance_of(String),
                 text: instance_of(String)} }

    it 'sends email to new user' do
      subject.should_receive(:send_email).with(data).once

      subject.perform email
    end
  end
end