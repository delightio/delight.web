class CreateBetaSignups < ActiveRecord::Migration
  def change
    create_table :beta_signups do |t|
      t.string :email
      t.string :app_name
      t.string :platform
      t.boolean :opengl
      t.boolean :unity3d

      t.timestamps
    end
  end
end
