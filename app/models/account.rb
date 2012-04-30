class Account < ActiveRecord::Base
  has_many :apps
  accepts_nested_attributes_for :apps
  attr_accessible :apps_attributes, :name, :administrator_id

  belongs_to :administrator
  has_many :permissions
  has_many :viewers, :through => :permissions

  validates :administrator_id, :presence => true
  validates :name, :presence => true

  include Redis::Objects
  counter :credits
  FreeCredits = 20

  def remaining_credits
    credits.to_i
  end

  def add_credits n
    credits.increment n
  end

  def use_credits n=1
    credits.decrement n
  end
end
