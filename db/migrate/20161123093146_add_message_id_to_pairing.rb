class AddMessageIdToPairing < ActiveRecord::Migration[5.0]
  def change
    add_column :pairings, :message_id, :string
  end
end
