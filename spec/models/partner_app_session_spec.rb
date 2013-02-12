require 'spec_helper'

describe PartnerAppSession do
  subject { FactoryGirl.create :partner_app_session }

  describe '#complete' do
    it 'notifies partner' do
      subject.should_receive :notify_partner

      subject.complete
    end
  end

  describe '#notify_partner' do
    it 'issues a callback with POST' do
      RestClient.should_receive(:post).with(subject.callback_url)

      subject.notify_partner
    end
  end
end