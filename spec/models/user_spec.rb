require 'spec_helper'

describe User do
  before(:each) do 
    @user = FactoryGirl.create(:user) 
  end 

  describe "find_or_create_for_twitter_oauth" do 
    before(:each) do 
      @auth_hash = { 
        'provider' => 'twitter',
        'uid' => 'twitter_uid',
        'info' => {
          'nickname' => 'mistralay',
          'name' => 'mistralay',
          'location' => 'Hong Kong',
          'image' => 'http://a0.twimg.com/profile_images/1575006751/profile_normal.jpg',
          'description' => '',
          'urls' => {
             'Website' => '',
             'Twitter' => 'http://twitter.com/mistralay'
           }
        },
        'credentials' => { 
          'token' => '16660949-jIK5eFanPaBIWB3AU5JmUYOEWx7D61sdKzpas8SQ2',
          'secret' => '8ao4MwpoXZnJQB2JteVIKmCsOmB50cnNvCk5x1V0vxU'
         }
      }
    end 

    describe "no existing user" do 
      it "should retrieve existing user" do 
        num_user = User.count 
#        num_account = Account.count 
        user = User.find_or_create_for_twitter_oauth(@auth_hash)
        user.twitter_id.should == 'twitter_uid'  
        User.count.should == (num_user+1)

#        # should have created an account
#        Account.count.should == (num_account+1)
#        user.account.should be_valid
      end 
    end 

    describe "there is existing user" do 
      before(:each) do 
        @twitter_user = FactoryGirl.create(:user, :twitter_id => 'twitter_uid') 
      end 
      it "should create new user" do 
        count = User.count 
        user = User.find_or_create_for_twitter_oauth(@auth_hash)
        user.twitter_id.should == 'twitter_uid'  
        User.count.should == count
        user.should == @twitter_user
      end 
    end 
  end 
end
