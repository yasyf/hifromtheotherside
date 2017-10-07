class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :yes_label, null: false
      t.string :no_label, null: false
      t.string :text, null: false
      t.belongs_to :preference, foreign_key: true, null: false

      t.timestamps
    end
  end
end
