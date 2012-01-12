class SwitchToSite < ActiveRecord::Migration
  def self.up
    #Alarm Changes
    add_column "alarms", "site_id", :integer
    remove_column "alarms", "switch_port_id"
    #Datalog Changes
    remove_index "datalogs", :name => "port_ts_idx"
    add_column "datalogs", "site_id", :integer
    remove_column "datalogs", "switch_port_id"
    add_index "datalogs", ["site_id", "ts"], :name => "site_ts_idx"
    drop_table "test_points"
    drop_table "trace_samples"
    drop_table "upstreams"
    drop_table "alarm_configs"
  end

  def self.down
    add_column "alarms", "switch_port_id", :integer
    remove_column "alarms", "site_id"
    remove_index "datalogs",:name =>"site_ts_idx"
    add_column "datalogs", "switch_port_id", :integer
    remove_column "datalogs", "site_id"
    add_index "datalogs", ["switch_port_id", "ts"], :name => "port_ts_idx"

  create_table "alarm_configs", :force => true do |t|
    t.column "alarm_name",          :string,  :default => "",   :null => false
    t.column "deviation",           :integer, :default => 0
    t.column "alarm_delay",         :integer, :default => 1
    t.column "transfer_trace_flag", :boolean, :default => true
    t.column "schedule_id",         :integer, :default => 1
  end
  create_table "test_points", :force => true do |t|
    t.column "site_id", :integer
  end

  create_table "trace_samples", :force => true do |t|
    t.column "ts",      :datetime
    t.column "rptp",    :integer,  :limit => 6
    t.column "freq",    :float
    t.column "minimum", :integer,  :limit => 6
    t.column "average", :integer,  :limit => 6
    t.column "maximum", :integer,  :limit => 6
  end

  create_table "upstreams", :force => true do |t|
    t.column "parent_id", :integer, :null => false
    t.column "child_id",  :integer, :null => false
  end

  end
end
