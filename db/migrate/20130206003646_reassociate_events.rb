class ReassociateEvents < ActiveRecord::Migration
  def change
    create_table :app_sessions_events do |t|
      t.references :app_session
      t.references :event
      t.references :track
      t.timestamps
    end

    add_index :app_sessions_events, [:app_session_id, :event_id, :track_id], name: 'ase_as_event_track_id'

    add_column :app_sessions, :app_sessions_events_count, :integer, default: 0
    add_column :events, :app_sessions_events_count, :integer, default: 0
    add_column :tracks, :app_sessions_events_count, :integer, default: 0

    execute <<-SQL
      INSERT INTO "app_sessions_events"
        (app_session_id, event_id, track_id, created_at, updated_at)
      SELECT app_sessions.id, events.id, tracks.id, date('now'), date('now')
        FROM events
      INNER JOIN "tracks" ON "tracks"."id" = "events"."track_id"
      INNER JOIN "app_sessions" ON "app_sessions"."id" = "tracks"."app_session_id"
    SQL

    update <<-SQL
      UPDATE app_sessions SET app_sessions_events_count = (
        SELECT count(*) FROM app_sessions_events
          WHERE app_sessions_events.app_session_id = app_sessions.id
      )
    SQL

    update <<-SQL
      UPDATE events SET app_sessions_events_count = (
        SELECT count(*) FROM app_sessions_events
          WHERE app_sessions_events.event_id = events.id
      )
    SQL

    update <<-SQL
      UPDATE tracks SET app_sessions_events_count = (
        SELECT count(*) FROM app_sessions_events
          WHERE app_sessions_events.track_id = tracks.id
      )
    SQL
  end
end
