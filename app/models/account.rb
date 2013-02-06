class Account < ActiveRecord::Base
  has_many :apps
  accepts_nested_attributes_for :apps
  attr_accessible :apps_attributes, :name, :administrator_id

  belongs_to :administrator
  has_many :permissions
  has_many :viewers, :through => :permissions

  validates :administrator_id, :presence => true
  validates :name, :presence => true

  after_create :add_free_credits, :email_new_signup

  include Redis::Objects
  counter :credits
  value :plan
  FreeCredits = 50
  SpecialCredits = 10

  def remaining_credits
    credits.to_i
  end

  def enough_credits? n=1
    remaining_credits >= n ||
    subscribed_to_unlimited_plan?
  end

  def add_credits n
    credits.increment n
  end

  def use_credits n=1
    unless subscribed_to_unlimited_plan?
      credits.decrement n
    end
  end

  def subscribed_to_unlimited_plan?
    current_subscription == 'unlimited'
  end

  def current_subscription
    plan.value
  end

  def subscribe new_plan
    plan.value = new_plan.to_s
  end

  def unsubscribe
    plan.delete
  end

  def add_free_credits
    add_credits FreeCredits + SpecialCredits
  end

  def email_new_signup
    Resque.enqueue ::NewAccountSignup, administrator.email
  end
end
