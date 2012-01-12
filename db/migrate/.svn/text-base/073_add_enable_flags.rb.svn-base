class AddEnableFlags < ActiveRecord::Migration
  def self.up
    add_column :cfg_channel_tests, :mer_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :preber_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :postber_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :video_lvl_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :varatio_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :enm_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :evm_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :dcp_flag, :boolean, :default => true, :null => false
  end
  
  def self.down
    remove_column :cfg_channel_tests, :mer_flag
    remove_column :cfg_channel_tests, :preber_flag
    remove_column :cfg_channel_tests, :postber_flag
    remove_column :cfg_channel_tests, :video_lvl_flag
    remove_column :cfg_channel_tests, :varatio_flag
    remove_column :cfg_channel_tests, :enm_flag
    remove_column :cfg_channel_tests, :evm_flag
    remove_column :cfg_channel_tests, :dcp_flag
  end
end
