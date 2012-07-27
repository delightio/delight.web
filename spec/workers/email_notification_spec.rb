require 'spec_helper'

describe EmailNotification do
  subject { EmailNotification }

  describe 'send_individual' do
    let(:credential) { {username: 'fdfd', password: 'fdfds'} }
    let(:data) { mock.as_null_object }

    it 'posts to mailgun server with api key' do
      subject.should_receive :verify_required_params
      subject.should_receive(:credential).twice.and_return(credential)
      RestClient.should_receive(:post).once

      subject.send_individual data
    end
  end

  describe 'verify_required_params' do
    let(:invalid) {   {to: mock, from: mock, bcc: mock, subject: mock} }
    let(:with_text) { {to: mock, from: mock, bcc: mock, subject: mock, text: mock} }
    let(:with_html) { {to: mock, from: mock, bcc: mock, subject: mock, html: mock} }

    it 'needs to, from, bcc, subject and one of text or html' do
      lambda { subject.verify_required_params with_text }.should_not raise_error
      lambda { subject.verify_required_params with_html }.should_not raise_error
      lambda { subject.verify_required_params invalid }.should raise_error
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