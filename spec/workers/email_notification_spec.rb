require 'spec_helper'

describe EmailNotification do
  subject { EmailNotification }

  describe 'send_individual' do
    let(:credential) { {username: 'fdfd', password: 'fdfds'} }
    let(:data) { mock.as_null_object }
    it 'posts to mailgun server with api key' do
      subject.should_receive(:credential).twice.and_return(credential)
      RestClient.should_receive(:post).once

      subject.send_individual data
    end
  end

  describe 'send_list' do
    it 'sends email to given email list'
  end

  describe 'subscribe' do
    it 'subscribes given email address to given email list'
  end

  describe 'create_list' do
    it 'creates email list'
  end
end