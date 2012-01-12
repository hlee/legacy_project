class AddLastipToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :live_ip, :string
  end

  def self.down
    remove_column :users, :live_ip
  end
end
