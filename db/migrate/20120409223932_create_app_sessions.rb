class CreateAppSessions < ActiveRecord::Migration
  def change
    create_table :app_sessions do |t|
      t.decimal :duration

      t.timestamps
    end
  end
end
