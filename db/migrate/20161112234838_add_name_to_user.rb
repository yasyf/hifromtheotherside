class AddNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, null: false, default: ""
    add_column :users, :last_name, :string, null: false, default: ""
    add_column :users, :zip, :string
    add_column :users, :supported, :integer
    add_column :users, :desired, :integer
    add_column :users, :background, :text
  end
end
