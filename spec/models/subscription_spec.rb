require 'spec_helper'

describe Subscription do
  let(:plan) { FactoryGirl.create :volume_plan }
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

  describe '#enough_quota?' do
    it 'is always true if subscribed to unlimited plan' do
      plan = FactoryGirl.create :time_plan
      subject = Subscription.create account_id:10, plan_id: plan.id

      subject.should be_enough_quota(10)
    end

    it 'is true if we have enough' do
      subject.should be_enough_quota(subject.remaining/2)
    end

    it 'is false if plan is expired' do
      subject.stub :expired? => true
      subject.should_not be_enough_quota(1)
    end
  end

  describe '#set_expired_at' do
    it 'sets expired_at after creation' do
      subject.expired_at.should_not be_nil
    end
  end

  describe '#expired?' do
    it 'is false if it has not been expired' do
      plan = FactoryGirl.create :quota_plan
      subscripton = Subscription.create account_id:10, plan_id: plan.id
      subscripton.should_not be_expired
    end

    it 'is true if plan has expired' do
      DateTime.should_receive(:now).and_return(1.years.from_now)

      subject.should be_expired
    end
  end

  describe '#notify' do
    it 'emails users about usage close to subscribed plan'
    it 'does nothing if we have previously notified user'
  end

  describe '#subscribe' do
    before {
      # To ensure we have a payment object
      subject = (FactoryGirl.create :payment).subscription
    }

    it 'creates payment object from given token'
    it 'updates card of existing customer'
    it 'subscribes to given plan'

    let(:exception) { mock }
    it 'returns false if payment was not successful' do
      subject.stub :new_customer? => false
      Payment.any_instance.should_receive(:subscribe).and_raise

      (subject.subscribe mock).should be_false
    end
  end
end
