class AddKeyToApiKeys < ActiveRecord::Migration
  def change
    add_column :api_keys, :key, :string
  end
end
