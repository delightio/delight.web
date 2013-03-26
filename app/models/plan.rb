class Plan < ActiveRecord::Base
  attr_accessible :name, :price

  has_many :subscriptions
  has_many :accounts, :through => :subscriptions

  def unlimited?
    false
  end
end