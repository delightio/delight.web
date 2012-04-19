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
          'image' => 'http://example.com/profile_normal.jpg',
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
        user = User.find_or_create_for_twitter_oauth(@auth_hash)
        user.twitter_id.should == 'twitter_uid'  
        user.nickname.should == 'mistralay' 
        user.image_url.should == 'http://example.com/profile_normal.jpg'
        User.count.should == (num_user+1)
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

  describe "find_or_create_for_github_oauth" do 
    before(:each) do 
      @auth_hash = { 
        'provider' => 'github',
        'uid' => 'github_uid',
        'info' => {
          'nickname' => 'mistralay',
          'name' => 'mistralay',
          'location' => 'Hong Kong',
          'description' => '',
        },
        'credentials' => { 
          'token' => '16660949-jIK5eFanPaBIWB3AU5JmUYOEWx7D61sdKzpas8SQ2',
          'secret' => '8ao4MwpoXZnJQB2JteVIKmCsOmB50cnNvCk5x1V0vxU'
        },
        'extra' => { 
          'raw_info' => { 
            'avatar_url' => 'http://example.com/github_avatar.jpg'
          } 
        } 
      }
    end 

    describe "no existing user" do 
      it "should retrieve existing user" do 
        num_user = User.count 
        user = User.find_or_create_for_github_oauth(@auth_hash)
        user.github_id.should == 'github_uid'  
        user.nickname.should == 'mistralay' 
        user.image_url.should == 'http://example.com/github_avatar.jpg'
        User.count.should == (num_user+1)
      end 
    end 

    describe "there is existing user" do 
      before(:each) do 
        @github_user = FactoryGirl.create(:user, :github_id => 'github_uid') 
      end 
      it "should create new user" do 
        count = User.count 
        user = User.find_or_create_for_github_oauth(@auth_hash)
        user.github_id.should == 'github_uid'  
        User.count.should == count
        user.should == @github_user
      end 
    end 
  end 

end
