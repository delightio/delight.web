class AddTimeOfEvents < ActiveRecord::Migration
  def change
    add_column :events, :time, :decimal
  end
end
