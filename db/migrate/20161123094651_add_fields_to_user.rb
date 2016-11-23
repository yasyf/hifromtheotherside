class AddFieldsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :geolocation, :json
    add_column :users, :ip, :string
    add_column :users, :info, :json
  end
end
