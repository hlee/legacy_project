class AddMeasureFreq < ActiveRecord::Migration
  def self.up
    add_column :cfg_channel_tests, :mvf_nominal, :float,  :default => 0,   :null => true
    add_column :cfg_channel_tests, :mvf_minor, :float,  :default => 0,   :null => true
    add_column :cfg_channel_tests, :mvf_major, :float,  :default => 0,   :null => true
    add_column :cfg_channel_tests, :mvf_flag, :boolean, :default => true, :null => false
    add_column :cfg_channel_tests, :maf_nominal, :float,  :default => 0,   :null => true
    add_column :cfg_channel_tests, :maf_minor, :float,  :default => 0,   :null => true
    add_column :cfg_channel_tests, :maf_major, :float,  :default => 0,   :null => true
    add_column :cfg_channel_tests, :maf_flag, :boolean, :default => true, :null => false
  end
  
  def self.down
    remove_column :cfg_channel_tests, :mvf_nominal
    remove_column :cfg_channel_tests, :mvf_minor
    remove_column :cfg_channel_tests, :mvf_major
    remove_column :cfg_channel_tests, :mvf_flag
    remove_column :cfg_channel_tests, :maf_nominal
    remove_column :cfg_channel_tests, :maf_minor
    remove_column :cfg_channel_tests, :maf_major
    remove_column :cfg_channel_tests, :maf_flag
  end
end
