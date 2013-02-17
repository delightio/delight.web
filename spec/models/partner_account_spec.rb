require 'spec_helper'

describe PartnerAccount do
  subject { FactoryGirl.create :partner_account }
  describe '#subscribed_to_unlimited_plan?' do
    it 'always subscribes to unlimited plan by default' do
      subject.should be_subscribed_to_unlimited_plan
    end
  end
end