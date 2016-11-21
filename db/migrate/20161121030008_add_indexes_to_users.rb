class AddIndexesToUsers < ActiveRecord::Migration[5.0]
  def up
    execute "create index on users using gin(to_tsvector('english', background));"
  end
end
