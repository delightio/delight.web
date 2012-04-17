require 'spec_helper'

describe Account do
  before(:each) do 
    @account = FactoryGirl.create(:account) 
    @account.should be_valid
  end 
  describe "during validation" do
    it "should require administrator_id" do 
      @account.administrator_id = nil 
      @account.should have(1).error_on(:administrator_id)
    end 
    it "should require name" do 
      @account.name = nil 
      @account.should have(1).error_on(:name)
    end 
  end 
end 
