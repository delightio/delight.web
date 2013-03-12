class AddNotifiedAtToSchedulers < ActiveRecord::Migration
  def change
    add_column :schedulers, :notified_at, :datetime
  end
end
