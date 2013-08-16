require 'spec_helper'

describe WebhooksController do
	describe 'post' do
    context 'when receiving a successful payment event' do
      it 'renews the subscription'
      it 'emails user receipt'
    end
    context 'when receiving a subscription change event' do
      it 'emails user about recent change'
    end
  end
end