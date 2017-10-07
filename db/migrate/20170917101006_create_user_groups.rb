class CreateUserGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :user_groups do |t|
      t.belongs_to :group, foreign_key: true, null: false
      t.belongs_to :user, foreign_key: true, null: false

      t.index [:user_id, :group_id], unique: true

      t.timestamps
    end
  end
end
