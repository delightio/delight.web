class Administrator < Viewer
  has_one :account
  accepts_nested_attributes_for :account
  attr_accessible :account_attributes
end
