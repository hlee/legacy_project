class SwitchAddMasterFlag < ActiveRecord::Migration
  def self.up
    add_column "switches", "master_switch_flag", :boolean, :default => false
    remove_column "switches", "master_switch_src"
  end

  def self.down
    remove_column "switches", "master_switch_flag"
    add_column "switches", "master_switch_src", :integer
  end
end
