class AddFidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fid, :string
    add_index :users, :fid
  end
end
