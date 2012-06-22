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
  FreeCredits = 50
  SpecialCredits = 10

  def remaining_credits
    credits.to_i
  end

  def add_credits n
    credits.increment n
  end

  def use_credits n=1
    credits.decrement n
  end

  def add_free_credits
    add_credits FreeCredits + SpecialCredits
  end

  def email_new_signup
    Resque.enqueue ::NewAccountSignup, administrator.email
  end
end
