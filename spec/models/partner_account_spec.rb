require 'spec_helper'

describe PartnerAccount do
  subject { FactoryGirl.create :partner_account }
  it 'always subscribes to unlimited plan by default' do
    subject.subscription.plan.should be_unlimited
  end
end