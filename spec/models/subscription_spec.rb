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

  describe '#auto_renew?' do
    it 'is true if plan is also auto renew' do
      free_plan = FactoryGirl.create :free_plan
      subject = Subscription.create account_id:10, plan_id:free_plan.id

      subject.should be_auto_renew
    end
  end

  describe '#renew' do
    it 'reset expired_at' do
      subject.expired_at.should_not be_nil
    end
    it 'resets usage' do
      subject.use 100

      expect { subject.renew }.
        to change { subject.usage }.from(100).to(0)
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
    # ensure we have a payment object
    let(:payment) { FactoryGirl.create :payment }
    before { subject.payment = payment }

    it 'creates payment object from given token'
    it 'updates card of existing customer'
    it 'subscribes to given plan'

    let(:exception) { mock }
    it 'returns false if payment was not successful' do
      subject.payment.should_receive(:subscribe).and_raise

      (subject.subscribe mock).should be_false
    end
  end
end
