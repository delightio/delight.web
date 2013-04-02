require 'stripe'

class Payment < ActiveRecord::Base
  attr_accessible :stripe_customer_id, :subscription_id
  belongs_to :subscription

  validates :stripe_customer_id, :presence => true
  validates :subscription_id, :presence => true

  def self.create_with_email_and_token(email, token, subscription_id)
    authenticate_stripe
    stripe = Stripe::Customer.create email: email, card: token
    create subscription_id: subscription_id, stripe_customer_id: stripe.id
  end

  def stripe_customer
    return @stripe_customer if @stripe_customer

    authenticate_stripe
    @stripe_customer = Stripe::Customer.retrieve stripe_customer_id
  end

  # Subscribe to plan pre created on Stripe
  def subscribe(plan)
    stripe_customer.update_subscription plan: plan.stripe_id
  end

  def card=(token)
    stripe_customer.card = token
    stripe_customer.save
  end
end

def authenticate_stripe
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
end
