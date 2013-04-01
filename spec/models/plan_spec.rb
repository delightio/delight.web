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
end
