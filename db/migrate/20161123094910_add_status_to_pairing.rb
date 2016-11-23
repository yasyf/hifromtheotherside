class AddStatusToPairing < ActiveRecord::Migration[5.0]
  def change
    add_column :pairings, :status, :integer, null: false, default: 0
  end
end
