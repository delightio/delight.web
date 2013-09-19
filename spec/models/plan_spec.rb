require 'spec_helper'

describe Plan do
  it { should_not be_unlimited }

  describe "#<=>" do
    let(:plan10) { Plan.new price: 10 }
    let(:plan20) { Plan.new price: 20 }

    it 'is upgrade if price is higher' do
      plan20.should > plan10
    end

    it 'is equal if same price' do
      plan10again = Plan.new price: 10
      plan10.should == plan10again
    end

    it 'is downgrade if price is lower' do
      plan10.should < plan20
    end
  end

  describe '#free?' do
    let(:free_plan) { Plan.new }
    let(:paid_plan) { Plan.new price:10 }

    it 'is true if plan has no price' do
      free_plan.should be_free
    end

    it 'is false if plan has a price' do
      paid_plan.should_not be_free
    end
  end

  describe '#auto_renew?' do
    let(:free_plan) { Plan.new price: 0 }
    it 'does when plan is free' do
      free_plan.should be_auto_renew
    end
  end
end
