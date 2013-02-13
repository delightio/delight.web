class RenameAppSessionsEventsToEventInfos < ActiveRecord::Migration
  def up
    rename_table :app_sessions_events, :event_infos

    rename_column :app_sessions, :app_sessions_events_count, :event_infos_count
    rename_column :events, :app_sessions_events_count, :event_infos_count
    rename_column :tracks, :app_sessions_events_count, :event_infos_count

    add_column :event_infos, :time, :decimal
    add_column :event_infos, :properties, :hstore

    update <<-SQL
      UPDATE event_infos SET time = (
        SELECT time FROM events
          WHERE events.id = event_infos.event_id
      )
    SQL

    update <<-SQL
      UPDATE event_infos SET properties = (
        SELECT properties FROM events
          WHERE events.id = event_infos.event_id
      )
    SQL

    remove_column :events, :time
    remove_column :events, :properties
  end

  def down
    add_column :events, :time, :decimal
    add_column :events, :properties, :hstore

    update <<-SQL
      UPDATE events SET time = (
        SELECT time FROM event_infos
          WHERE events.id = event_infos.event_id
      )
    SQL

    update <<-SQL
      UPDATE events SET properties = (
        SELECT properties FROM event_infos
          WHERE events.id = event_infos.event_id
      )
    SQL

    remove_column :event_infos, :time
    remove_column :event_infos, :properties

    rename_column :tracks, :event_infos_count, :app_sessions_events_count
    rename_column :app_sessions, :event_infos_count, :app_sessions_events_count
    rename_column :events, :event_infos_count, :app_sessions_events_count

    rename_table :event_infos, :app_sessions_events
  end
end
