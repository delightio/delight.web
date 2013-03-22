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

  describe '#update_usage' do
    let(:cost) { 10.34 }
    it 'updates subscription' do
      subject.subscription.should_receive(:use).with(cost)

      subject.update_usage cost
    end

    it 'handles over usage' do
      subject.subscription.should_receive(:enough_quota?).
        and_return(false)
      subject.should_receive(:handle_over_usage)

      subject.update_usage cost
    end
  end

  describe '#handle_over_usage' do
    it 'stops all recordings' do
      subject.apps.each do |app|
        app.should_receive(:stop_recording)
      end

      subject.handle_over_usage
    end

    it 'notifies user' do
      subject.subscription.should_receive(:notify)

      subject.handle_over_usage
    end
  end

  describe '#subscribe_free_plan' do
    it 'subscribes to free plan' do
      subject.should_receive(:subscribe).with(FreePlan.id)

      subject.subscribe_free_plan
    end
  end
end
