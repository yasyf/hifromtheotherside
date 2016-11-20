class AddPairedToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :paired, :boolean, null: false, default: false
  end
end
