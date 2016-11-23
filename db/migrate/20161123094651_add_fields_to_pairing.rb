class AddFieldsToPairing < ActiveRecord::Migration[5.0]
  def change
    add_column :pairings, :geolocation, :json
    add_column :pairings, :ip, :string
    add_column :pairings, :info, :json
  end
end
