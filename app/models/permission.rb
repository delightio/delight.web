class Permission < ActiveRecord::Base
  belongs_to :viewer
  belongs_to :app 
end
