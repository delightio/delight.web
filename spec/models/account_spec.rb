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

  # describe '#remaining_credits' do
  #   it 'is a number' do
  #     subject.remaining_credits.should be_an_instance_of Fixnum
  #   end

  #   it 'can be negative' do
  #     subject.use_credits subject.remaining_credits + 20

  #     subject.remaining_credits.should < 0
  #   end
  # end

  # describe '#enough_credits?' do
  #   it 'asks subscription if we still have enough quota' do
  #     subject.subscription.should_receive(:enough_quota?).with(12)
  #     subject.enough_credits? 12
  #   end
  # end

  # let(:credit_change) { 20 }

  # describe '#add_credits' do
  #   it 'increments credits by given amount' do
  #     expect { subject.add_credits credit_change }.
  #       to change { subject.remaining_credits }.by credit_change
  #   end

  #   # Account controller expects #add_credits to return the updated credits
  #   it 'returns the updated credits' do
  #     original = Account::FreeCredits + Account::SpecialCredits
  #     subject.add_credits(credit_change).should == (credit_change + original)
  #   end
  # end

  # describe '#use_credits' do
  #   it 'decrements credits by given amount' do
  #     expect { subject.use_credits credit_change }.
  #       to change { subject.remaining_credits }.by (-1*credit_change)
  #   end

  #   context 'when subscribed to unlimited plan' do
  #     before { subject.stub :subscribed_to_unlimited_plan? => true }
  #     it 'does not decrement credits' do
  #       subject.subscription.should_not_receive :use

  #       subject.use_credits credit_change
  #     end
  #   end
  # end

  # describe '#subscribed_to_unlimited_plan?' do
  #   let(:unlimited_plan) { 'unlimited' }
  #   it 'is true after we subscribe' do
  #     subject.subscribe unlimited_plan

  #     subject.should be_subscribed_to_unlimited_plan
  #   end

  #   it 'is false if we did not subscribe' do
  #     subject.unsubscribe

  #     subject.should_not be_subscribed_to_unlimited_plan
  #   end
  # end

  describe '#subscribe_free_plan' do
    it 'subscribes to free plan' do
      free_plan = VolumePlan.find_by_name 'free'
      subject.should_receive(:subscribe).with(free_plan.id)

      subject.subscribe_free_plan
    end
  end

end
