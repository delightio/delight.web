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
    before :each do
      subject.callback_payload = { user_id: 123, properties: [1,2,3] }
      subject.save
    end

    it 'issues a callback with POST' do
      RestClient.should_receive(:post).
        with(subject.callback_url, callback_payload: subject.callback_payload)

      subject.notify_partner
    end

    it 'does not throw error if we cannot reach the callback_url' do
      RestClient.should_receive(:post).and_raise

      expect { subject.notify_partner }.
        to_not raise_error
    end
  end
end