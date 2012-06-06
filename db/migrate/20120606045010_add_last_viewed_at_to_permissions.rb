class AddLastViewedAtToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :last_viewed_at, :datetime
    App.all.each do |app|
      admin = app.account.administrator
      if not app.viewers.include? admin
        app.viewers << admin
      end
    end
  end
end
