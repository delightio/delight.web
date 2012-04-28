class Administrator < Viewer
  has_one :account
  #has_many :account_apps, :through => :account, :source => :apps
  #accepts_nested_attributes_for :account_apps
  #attr_accessible :account_apps_attributes
end
