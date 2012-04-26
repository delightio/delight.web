require 'spec_helper'

describe EmailNotification do
  subject { EmailNotification }

  describe 'send' do
    let(:emails) { ['abc'] }
    let(:credential) { {username: 'fdfd', password: 'fdfds'} }
    it 'posts to mailgun server with api key' do
      subject.should_receive(:credential).twice.and_return(credential)
      RestClient.should_receive(:post).once

      subject.send emails, mock, mock
    end
  end
end