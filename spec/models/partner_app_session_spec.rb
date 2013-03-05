require 'spec_helper'

describe PartnerAppSession do
  subject { (FactoryGirl.create :partner_app_session).
              tap do |s|
                s.stub :presentation_track => mock.as_null_object
                s.stub :gesture_track => mock.as_null_object
              end }

  describe '#complete' do
    it 'notifies partner' do
      subject.should_receive :notify_partner

      subject.complete
    end
  end

  describe '#notify_partner' do
    it 'issues a callback with POST' do
      RestClient.should_receive(:post).
        with(subject.callback_url, subject.to_hash)

      subject.notify_partner
    end

    it 'does not throw error if we cannot reach the callback_url' do
      RestClient.should_receive(:post).and_raise

      expect { subject.notify_partner }.
        to_not raise_error
    end
  end

  describe '#to_hash' do
    before :each do
      subject.callback_payload = Hash[:user => 'thomas']
    end

    it 'includes callback payload' do
      subject.to_hash[:callback_payload].should == subject.callback_payload
    end

    it 'includes json url to gesture track' do
      subject.to_hash.should have_key(:gesture_track)
    end

    it 'includes json url to presentation track' do
      subject.to_hash.should have_key(:presentation_track)
    end

    it 'includes url to thumbnail' do
      subject.to_hash.should have_key(:thumbnail_url)
    end
  end
end