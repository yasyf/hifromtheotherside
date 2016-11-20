class AddSubscribeToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :subscribe, :boolean, null: false, default: true
  end
end
