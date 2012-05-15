class DeleteAppUserIdInAppSessions < ActiveRecord::Migration
  def up
    AppSession.find_each do |app_session|
      next if app_session.app_user_id.nil?
      app_session.update_properties app_user_id: app_session.app_user_id
    end

    remove_column :app_sessions, :app_user_id
  end

  def down
    add_column :app_sessions, :app_user_id, :string

    Property.where(:key => :app_user_id).find_each do |property|
      property.app_session.update_attributes app_user_id: property.value
    end
  end
end
