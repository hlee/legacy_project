class CreateCfgChannelTests < ActiveRecord::Migration
  def self.up
    create_table :cfg_channel_tests do |t|
      t.column "cfg_channel_id",          :integer,  :default => 0,   :null => false
      t.column "switch_port_id",          :integer,     :null => true
      t.column "mer_nominal",             :float,  :default => 0,   :null => true
      t.column "mer_minor",             :float,  :default => 0,   :null => true
      t.column "mer_major",             :float,  :default => 0,   :null => true
      t.column "preber_nominal",             :float,  :default => 0,   :null => true
      t.column "preber_minor",             :float,  :default => 0,   :null => true
      t.column "preber_major",             :float,  :default => 0,   :null => true
      t.column "postber_nominal",             :float,  :default => 0,   :null => true
      t.column "postber_minor",             :float,  :default => 0,   :null => true
      t.column "postber_major",             :float,  :default => 0,   :null => true
      t.column "video_lvl_nominal",             :float,  :default => 0,   :null => true
      t.column "video_lvl_minor",             :float,  :default => 0,   :null => true
      t.column "video_lvl_major",             :float,  :default => 0,   :null => true
      t.column "varatio_nominal",             :float,  :default => 0,   :null => true
      t.column "varatio_minor",             :float,  :default => 0,   :null => true
      t.column "varatio_major",             :float,  :default => 0,   :null => true


      t.column "enm_nominal",             :float,  :default => 0,   :null => true
      t.column "enm_minor",             :float,  :default => 0,   :null => true
      t.column "enm_major",             :float,  :default => 0,   :null => true
      t.column "evm_nominal",             :float,  :default => 0,   :null => true
      t.column "evm_minor",             :float,  :default => 0,   :null => true
      t.column "evm_major",             :float,  :default => 0,   :null => true
      t.column "dcp_nominal",             :float,  :default => 0,   :null => true
      t.column "dcp_minor",             :float,  :default => 0,   :null => true
      t.column "dcp_major",             :float,  :default => 0,   :null => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :cfg_channel_tests
  end
end
