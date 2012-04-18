class Account < ActiveRecord::Base
  has_many :apps
  belongs_to :administrator
  has_many :permissions
  has_many :viewers, :through => :permissions

  validates :administrator_id, :presence => true
  validates :name, :presence => true

  include Redis::Objects
  counter :credits
  after_create :set_default_credits

  def set_default_credits
    add_credits 50
  end

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
