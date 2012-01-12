class AddPolarity < ActiveRecord::Migration
  def self.up
    add_column :cfg_channels, :polarity, :integer,  :default => 0,   :null => true
  end

  def self.down
    remove_column :cfg_channels, :polarity
  end
end
