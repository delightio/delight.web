require 'spec_helper'

describe Payment do
  subject { FactoryGirl.create :payment }

  describe '#stripe_customer' do
    it 'returns the Stripe customer object'
  end

  describe '#subscribe' do
    it 'subscribes to given plan on Stripe'
  end

  describe '#card=' do
    it 'updates credit card on file'
  end
end
