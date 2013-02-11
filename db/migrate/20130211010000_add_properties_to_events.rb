class AddPropertiesToEvents < ActiveRecord::Migration
  def up
    add_column :events, :properties, :hstore
    execute "CREATE INDEX events_properties ON events USING GIN(properties)"
  end

  def down
    execute "DROP INDEX events_properties"
    remove_column :events, :properties
  end
end
