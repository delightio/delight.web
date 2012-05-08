class ChangeAppSessionsToSupportApi2 < ActiveRecord::Migration
  def up
    rename_column :app_sessions, :locale, :app_locale

    add_column :app_sessions, :app_connectivity, :string
    add_column :app_sessions, :device_hw_version, :string
    add_column :app_sessions, :device_os_version, :string

    AppSession.find_each do |as|
      [:app_connectivity, :device_hw_version, :device_os_version].each do |at|
        as.update_attribute at, ""
      end
    end
  end

  def down
    remove_column :app_sessions, :device_os_version
    remove_column :app_sessions, :device_hw_version
    remove_column :app_sessions, :app_connectivity

    rename_column :app_sessions, :app_locale, :locale
  end
end
