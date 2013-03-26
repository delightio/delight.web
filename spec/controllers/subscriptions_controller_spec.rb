require 'spec_helper'

describe SubscriptionsController do
  let(:account) { FactoryGirl.create :account }
  let(:plan) { FactoryGirl.create :volume_plan }
  before { sign_in(FactoryGirl.create :user) }

  describe 'POST create' do
    let(:params) { {account_id: account.id, plan_id: plan.id} }
    it 'creates new subscription' do
      post :create, subscription: params, format: :json
      response.should be_success

      id = JSON.parse(response.body)["id"]
      subscription = Subscription.find id
      subscription.plan.should == plan
      subscription.account.should == account
    end

    it 'does not create if missing account id' do
      params.delete :account_id
      post :create, subscription: params, format: :json
      response.should_not be_success
    end

    it 'does not create if missing plan id' do
      params.delete :plan_id
      post :create, subscription: params, format: :json
      response.should_not be_success
    end
  end

  describe 'PUT update' do
    let(:subscription) { FactoryGirl.create :subscription }

    it 'updates new plan' do
      new_plan = FactoryGirl.create :volume_plan
      params = { plan_id: new_plan.id }
      put :update, id: subscription.id, subscription: params, format: :json
      response.should be_success
      subscription.reload.plan.should == new_plan
    end
  end

  describe 'GET show' do
    let(:subscription) { FactoryGirl.create :subscription }
    it 'shows usage and days to be expired' do
      get :show, id: subscription.id
      response.should be_success
      json = JSON.parse(response.body)
      json.should have_key("plan_id")
      json.should have_key("account_id")
      json.should have_key("usage")
      json.should have_key("expired_at")
    end
  end
end
