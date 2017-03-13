class CreateGiftCards < ActiveRecord::Migration[5.0]
  def change
    create_table :gift_cards do |t|
      t.string :store, null: false
      t.string :url, null: false
      t.string :challenge, null: false
      t.bigint :number, null: false
      t.integer :amount, null: false
      t.belongs_to :pairing

      t.timestamps
    end
  end
end
