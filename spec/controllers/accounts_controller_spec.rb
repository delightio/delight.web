require 'spec_helper'

describe AccountsController do
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in(@user)
  end

  describe "POST 'create'" do
    it "redirect to apps index" do
      post 'create', { :account => { :name => 'account name' } }
      assigns(:account).name.should == 'account name'
      @user.reload
      @user.type.should == 'Administrator'
      response.should redirect_to(apps_path)
    end

    it 'adds free credits to each newly created account' do
      post 'create', { :account => { :name => 'account name' } }
      admin = Administrator.find @user.id
      admin.account.remaining_credits.should == Account::FreeCredits
    end

    it "should fail for missing name" do
      post 'create', {}
      flash[:type].should == 'error'
      @user.type.should == 'User'
    end

    describe "user already have an account" do
      let(:admin) { FactoryGirl.create(:administrator) }

      before(:each) do
        sign_out(@user)
        sign_in(admin)
      end

      it "should redirect user to apps listing" do
        post 'create', { :account => { :name => 'account name' } }
        response.should redirect_to(apps_path)
      end
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    let(:account) { FactoryGirl.create(:account) }
    let(:admin) { account.administrator }
    before(:each) do
      sign_out(@user)
      sign_in(admin)
    end

    it "returns http success" do
      get 'edit', { :id => admin.account.id }
      response.should be_success
    end

    it "should fail if user does not own the account" do
      @some_account = FactoryGirl.create(:account)
      get 'edit', { :id => @some_account.id }
      response.should redirect_to(root_path)
    end

    it "should fail if someone else signed in " do
      sign_out(admin)
      sign_in(@user)
      get 'edit', { :id => admin.account.id }
      response.should redirect_to(root_path)
    end
  end

  describe "GET 'show'" do
    let(:account) { FactoryGirl.create(:account) }
    let(:admin) { account.administrator }
    before(:each) do
      sign_out(@user)
      sign_in(admin)
    end

    it "returns http success" do
      get 'show', { :id => admin.account.id }
      response.should be_success
    end

    it "should redirect when id is not given" do
      get 'show'
      response.should redirect_to(root_path)
    end

    it "should redirect when id not owned by signed in user" do
      @some_account = FactoryGirl.create(:account)
      get 'show', { :id => @some_account.id }
      response.should redirect_to(root_path)
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @account = FactoryGirl.create(:account)
      sign_in(@account.administrator)
    end

    it "should succeed" do
      put 'update', { :id => @account.id, :account => { :name => 'new_name' } }
      response.should redirect_to(account_path(@account))
      @account.reload
      @account.name.should == 'new_name'
    end

    it "should render edit when missing param" do
      put 'update', { :id => @account.id }
      response.should redirect_to(root_path)
    end

    it "should render edit when not owned by signed in user" do
      @some_account = FactoryGirl.create(:account)
      put 'update', { :id => @some_account.id }
      response.should redirect_to(root_path)
    end
  end

#  describe "GET 'destroy'" do
#    it "returns http success" do
#      get 'destroy'
#      response.should be_success
#    end
#  end

end
