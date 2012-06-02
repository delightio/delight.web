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
  end

end
