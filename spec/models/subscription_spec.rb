require 'spec_helper'

describe Subscription do
  let(:plan) { FactoryGirl.create :quota_plan }
  subject { Subscription.create account_id:10, plan_id: plan.id }

  describe '#use' do
    it 'updates the usage' do
      # TODO: Not sure why the following is throwing an error
      # expect { subject.use 10 }.to change(subject.usage).by(10)
      # Failure/Error: expect { subject.use 10 }.to change(subject.usage).by(10)
      # TypeError:
      #   nil is not a symbol

      subject.usage.should == 0
      subject.use 10
      subject.usage.should == 10
    end
  end

  describe '#remaining' do
    it 'is the remaining quota' do
      subject.use 15
      subject.remaining.should == (subject.plan.quota-15)
    end
  end

  describe '#unlimited_plan?' do
    let(:plan) { FactoryGirl.create :time_plan }
    subject { Subscription.create account_id:10, plan_id: plan.id }

    it { should be_unlimited_plan}
  end
end