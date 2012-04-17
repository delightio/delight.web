class Viewer < User 
  has_many :permissions
  has_many :apps, :through => :permissions
end 
