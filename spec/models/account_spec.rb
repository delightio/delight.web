require 'spec_helper'

describe Account do
  subject { FactoryGirl.create :account }

  describe "during validation" do
    it "should require administrator_id" do
      subject.administrator_id = nil

      subject.should have(1).error_on(:administrator_id)
    end

    it "should require name" do
      subject.name = nil

      subject.should have(1).error_on(:name)
    end
  end

  describe 'after_create' do
    it 'email administrator' do
      Resque.should_receive(:enqueue).
        with(::NewAccountSignup, instance_of(String)).once

      FactoryGirl.create :account
    end
  end

  describe '#remaining_credits' do
    it 'is a number' do
      subject.remaining_credits.should be_an_instance_of Fixnum
    end

    it 'can be negative' do
      subject.use_credits subject.remaining_credits + 20

      subject.remaining_credits.should < 0
    end
  end

  describe '#enough_credits?' do
    it 'is always true if we subscribed to an unlimited plan' do
      subject.stub :subscribed_to_unlimited_plan? => true

      subject.should be_enough_credits(1000)
    end

    context 'when we do not subscribe to unlimited plan' do
      before { subject.stub :subscribed_to_unlimited_plan? => false }

      it 'is true when we have more remaining credit than requested' do
        subject.stub :remaining_credits => 10

        subject.should be_enough_credits(5)
      end

      it 'is false if we do not have enough credits' do
        subject.stub :remaining_credits => 10

        subject.should_not be_enough_credits(20)
      end
    end
  end

  let(:credit_change) { 20 }

  describe '#add_credits' do
    it 'increments credits by given amount' do
      expect { subject.add_credits credit_change }.
        to change { subject.remaining_credits }.by credit_change
    end
  end

  describe '#use_credits' do
    it 'decrements credits by given amount' do
      expect { subject.use_credits credit_change }.
        to change { subject.remaining_credits }.by (-1*credit_change)
    end

    context 'when subscribed to unlimited plan' do
      before { subject.stub :subscribed_to_unlimited_plan? => true }
      it 'does not decrement credits' do
        subject.credits.should_not_receive :decrement

        subject.use_credits credit_change
      end
    end
  end

  describe '#subscribed_to_unlimited_plan?' do
    let(:unlimited_plan) { 'unlimited' }
    it 'is true after we subscribe' do
      subject.subscribe unlimited_plan

      subject.should be_subscribed_to_unlimited_plan
    end

    it 'is false if we did not subscribe' do
      subject.unsubscribe

      subject.should_not be_subscribed_to_unlimited_plan
    end
  end

  describe '#add_free_credits' do
    it 'add free credits upon creation' do
      Account.any_instance.should_receive(:add_free_credits).once

      FactoryGirl.create :account
    end

    it 'add default FreeCredits' do
      subject.should_receive(:add_credits).
        with(Account::FreeCredits + Account::SpecialCredits).once

      subject.add_free_credits
    end
  end

end
