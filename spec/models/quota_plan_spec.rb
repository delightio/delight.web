require 'spec_helper'

describe QuotaPlan do
  describe 'price' do
    it 'returns optimized price for given credits' do
      QuotaPlan.price(50+50).should == 200
      QuotaPlan.price(50+50+20).should == 250
      QuotaPlan.price(20).should == 50
    end
  end

  describe 'customize' do
    it 'looks up or creates a new plan based on input param' do
      new_plan = QuotaPlan.customize 100, 200
      (QuotaPlan.customize 100, 200).should == new_plan
    end
  end
end
