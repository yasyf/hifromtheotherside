class CreatePairings < ActiveRecord::Migration[5.0]
  def change
    create_table :pairings do |t|
      t.integer :user_1_id, null: false, index: true
      t.integer :user_2_id, null: false, index: true

      t.timestamps
    end

    add_index :pairings, [:user_1_id, :user_2_id], unique: true
    add_index :pairings, [:user_2_id, :user_1_id], unique: true
  end
end
