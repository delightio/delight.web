require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  specify 'it has an valid email' do
    @user.email = 'fdfdsf'
    @user.should have(1).error_on(:email)
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
      it "should create user" do
        num_user = User.count
        user = User.find_or_create_for_twitter_oauth(@auth_hash, nil, 'Administrator')
        user.twitter_id.should == 'twitter_uid'
        user.nickname.should == 'mistralay'
        user.image_url.should == 'http://example.com/profile_normal.jpg'
        user.twitter_url.should == 'http://twitter.com/mistralay'
        User.count.should == (num_user+1)
        user.type.should == 'Administrator'
      end
    end

    describe "there is existing user" do
      before(:each) do
        @twitter_user = FactoryGirl.create(:user, :twitter_id => 'twitter_uid')
      end
      it "should retrieve existing user" do
        count = User.count
        user = User.find_or_create_for_twitter_oauth(@auth_hash)
        user.twitter_id.should == 'twitter_uid'
        User.count.should == count
        user.twitter_url.should == 'http://twitter.com/mistralay'
        user.should == @twitter_user
        user.type.should == 'User'
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
          'urls' => {
             'GitHub' => 'http://github.com/xxx'
           }
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
      it "should create new user" do
        num_user = User.count
        user = User.find_or_create_for_github_oauth(@auth_hash, nil, 'Administrator', 'over@example.com')
        user.github_id.should == 'github_uid'
        user.nickname.should == 'mistralay'
        user.image_url.should == 'http://example.com/github_avatar.jpg'
        User.count.should == (num_user+1)
        user.type.should == 'Administrator'
        user.email.should == 'over@example.com'
        user.github_url.should == 'http://github.com/xxx'
      end
    end

    describe "there is existing user" do
      before(:each) do
        @github_user = FactoryGirl.create(:user, :github_id => 'github_uid')
      end
      it "should retrieve existing user" do
        count = User.count
        user = User.find_or_create_for_github_oauth(@auth_hash, nil, 'Viewer', 'overide@example.com')
        user.github_id.should == 'github_uid'
        User.count.should == count
        user.should == @github_user
        user.type.should == 'User' # should respec original type
        user.email.should_not == 'overide@example.com'
        user.github_url.should == 'http://github.com/xxx'
      end
    end
  end

  describe 'association' do
    let(:user) { FactoryGirl.create(:user) }
    let(:app_session) { FactoryGirl.create(:app_session) }

    it "should assign favorite user correctly" do
      user.favorite_app_sessions.should == []
      user.favorite_app_sessions << app_session
      user.favorite_app_sessions.should == [app_session]
    end
  end

  describe 'profile_url' do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      user.twitter_url = 'turl'
      user.github_url = 'gurl'
    end

    describe 'twitter user' do
      before(:each) do
        user.twitter_id = '123'
      end
      it "should return twitter url" do
        user.profile_url.should == 'turl'
      end
    end
    describe 'github user' do
      before(:each) do
        user.github_id = '123'
      end
      it "should return github url" do
        user.profile_url.should == 'gurl'
      end
    end
  end

end
