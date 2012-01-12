class SwitchNameLonger < ActiveRecord::Migration
  def self.up
    change_column "switches", "switch_name", :string, :length => 50
  end

  def self.down
    change_column "switches", "switch_name", :string, :length => 11
  end
end
