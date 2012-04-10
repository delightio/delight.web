class AddLocaleToAppSessions < ActiveRecord::Migration
  def change
    add_column :app_sessions, :locale, :string

  end
end
