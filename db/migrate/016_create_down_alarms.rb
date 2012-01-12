class CreateDownAlarms < ActiveRecord::Migration
  def self.up
    create_table "down_alarms", :force => true do |t|
      t.column "site_id",         :integer, :null => false
      t.column "sf_test_plan_id",        :integer, :null=>false
      t.column "external_temp",       :integer, :default => true
      t.column "channel_id",         :integer 
      t.column "measure_id",         :integer 
      t.column "val",                :float
      t.column "type",               :integer, :null=>false
    end
  end

  def self.down
          #    drop_table :down_alarms
  end
end
