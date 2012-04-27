require 'spec_helper'

describe Administrator do
  let(:app) { FactoryGirl.create(:app) }
  let(:account) { app.account }
  let(:admin) { account.administrator }

  #describe "account apps" do
  #  it "should work" do
  #    admin.account_apps.should == [app]
  #  end
  #end
end

