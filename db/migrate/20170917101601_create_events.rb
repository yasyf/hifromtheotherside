class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :logo, null: false

      t.index :code, unique: true

      t.timestamps
    end
  end
end
