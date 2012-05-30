require 'spec_helper'

describe EmailNotification do
  subject { EmailNotification }

  describe 'send_text' do
    let(:credential) { {username: 'fdfd', password: 'fdfds'} }
    let(:data) { mock.as_null_object }
    it 'posts to mailgun server with api key' do
      subject.should_receive(:credential).twice.and_return(credential)
      RestClient.should_receive(:post).once

      subject.send_text data
    end
  end
end