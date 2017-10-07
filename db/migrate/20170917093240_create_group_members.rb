class CreateGroupMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :group_members do |t|
      t.belongs_to :group, foreign_key: true, null: false
      t.belongs_to :question, foreign_key: true, null: false

      t.index [:question_id, :group_id], unique: true

      t.timestamps
    end
  end
end
