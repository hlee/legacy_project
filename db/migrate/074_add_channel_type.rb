class AddChannelType < ActiveRecord::Migration
  def self.up
    add_column :channels, :channel_type, :string,  :limit => 1
    add_column :channels, :site_id, :integer
    add_column :channels, :modulation, :integer
  end

  def self.down
    remove_column :channels, :channel_type
    remove_column :channels, :site_id
    remove_column :channels, :modulation
  end
end
