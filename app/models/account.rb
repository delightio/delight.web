class Account < ActiveRecord::Base
  has_many :apps
  belongs_to :administrator
  has_many :permissions
  has_many :viewers, :through => :permissions

  validates :administrator_id, :presence => true 
  validates :name, :presence => true
end
