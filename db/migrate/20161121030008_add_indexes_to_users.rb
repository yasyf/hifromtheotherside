class AddIndexesToUsers < ActiveRecord::Migration[5.0]
  def up
    execute "CREATE INDEX IF NOT EXISTS gin_background_idx ON users USING gin(to_tsvector('english', background));"
  end
end
