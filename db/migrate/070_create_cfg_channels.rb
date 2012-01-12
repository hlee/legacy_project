class CreateCfgChannels < ActiveRecord::Migration
  def self.up
    create_table :cfg_channels do |t|
      t.column "analyzer_id",          :integer,  :default => 0,   :null => false
      t.column "system_file_name",          :string,  :default => "",   :null => false
      t.column "channel",          :string,  :default => "",   :null => false
      t.column "channel_name",          :string,  :default => "",   :null => false
      t.column "freq",          :integer,  :default => 55000000,   :null => false
      t.column "modulation",          :integer,  :default => 0,   :null => false
      t.column "annex",          :integer,  :default => 0,   :null => false
      t.column "symbol_rate",          :integer,  :default => 0,   :null => false
      t.column "bandwidth",          :integer,  :default => 6000000,   :null => false
      t.column "audio_offset1",          :integer,  :default => 0,   :null => false
      t.column "audio_offset2",          :integer,  :default => 0,   :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :cfg_channels
  end
end
