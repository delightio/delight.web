class CreateFunnels < ActiveRecord::Migration
  def change
    create_table :funnels do |t|
      t.string :name
      t.references :app
      t.timestamps
    end

    create_table :events_funnels do |t|
      t.references :event
      t.references :funnel
      t.timestamps
    end

    add_index :funnels, :app_id
    add_index :events_funnels, [:event_id, :funnel_id]
  end
end
