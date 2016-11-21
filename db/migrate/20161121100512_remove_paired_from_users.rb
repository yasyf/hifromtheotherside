class RemovePairedFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :paired, :boolean
  end
end
