class BaselineSchema < ActiveRecord::Migration
  def self.up
  create_table "alarm_configs", :force => true do |t|
    t.column "alarm_name",          :string,  :default => "",   :null => false
    t.column "deviation",           :integer, :default => 0
    t.column "alarm_delay",         :integer, :default => 1
    t.column "transfer_trace_flag", :boolean, :default => true
    t.column "schedule_id",         :integer, :default => 1
  end

  create_table "alarms", :force => true do |t|
    t.column "sched_sn_nbr",         :integer
    t.column "step_nbr",             :integer
    t.column "monitoring_mode",      :integer
    t.column "calibration_status",   :integer,  :limit => 1
    t.column "event_time",           :datetime
    t.column "event_time_hundreths", :integer,  :limit => 6
    t.column "alarm_level",          :integer,  :limit => 6
    t.column "alarm_deviation",      :integer
    t.column "external_temp",        :integer
    t.column "image",                :binary
    t.column "switch_port_id",       :integer
    t.column "state",                :string,   :limit => 1
    t.column "span",                 :float
    t.column "center_frequency",     :float
    t.column "alarm_type",           :string,   :limit => 1
  end

  add_index "alarms", ["event_time"], :name => "alarm_time_idx"

  create_table "analyzers", :force => true do |t|
    t.column "name",               :string
    t.column "ip",                 :string
    t.column "switch_network",     :boolean
    t.column "baud_rate",          :integer, :limit => 4
    t.column "switch_type",        :integer, :limit => 4
    t.column "bidirectional_flag", :boolean, :default=>true
    t.column "port_nbr",           :integer, :limit => 4
    t.column "port_count",         :integer, :default => 16
    t.column "sf_system_file_id",  :integer
    t.column "switch_port_id",     :integer
    t.column "attenuator",         :float, :default=> 10
    t.column "ref_offset",         :integer, :default => 1
    t.column "resol_bwd",          :integer, :default => 300_000
    t.column "video_bwd",          :float, :default => 100_000
    t.column "location",           :string
    t.column "cmd_port",           :integer
    t.column "status",             :integer
    t.column "pid",                :integer
  end

  create_table "channels", :force => true do |t|
    t.column "channel",      :integer
    t.column "channel_name", :string,  :limit => 32
  end

  create_table "config_params", :force => true do |t|
    t.column "name",      :string
    t.column "ident",     :integer
    t.column "data_type", :integer
    t.column "size",      :string
    t.column "uom",       :string
    t.column "descr",     :text
    t.column "category",  :string
    t.column "val",       :string
  end


  create_table "datalogs", :force => true do |t|
    t.column "ts",             :datetime
    t.column "sample_count",   :integer
    t.column "attenuation",    :float
    t.column "start_freq",     :float
    t.column "stop_freq",      :float
    t.column "min_val",        :float
    t.column "val",            :float
    t.column "max_val",        :float
    t.column "switch_port_id", :integer
  end

  add_index "datalogs", ["switch_port_id", "ts"], :name => "port_ts_idx"

  create_table "limits", :force => true do |t|
    t.column "measure_id", :integer, :default => 0
    t.column "channel_id", :integer, :default => 0
    t.column "site_id",    :integer, :default => 0
    t.column "max_val",    :float
    t.column "min_val",    :float
  end

  add_index "limits", ["site_id", "measure_id", "channel_id"], :name => "limit_data_idx"

  create_table "measurements", :force => true do |t|
    t.column "measure_id", :integer
    t.column "site_id",    :integer
    t.column "channel_id", :integer
    t.column "value",      :float
    t.column "dt",         :datetime
  end

  create_table "measures", :force => true do |t|
    t.column "measure_name", :string
    t.column "dec_places",   :integer, :default => 2
  end

  create_table "profiles", :force => true do |t|
    t.column "name",         :string,  :limit => 9
    t.column "comment",      :string,  :limit => 41
    t.column "trace",        :binary
    t.column "status",       :boolean
    t.column "major_offset", :float
    t.column "minor_offset", :float
    t.column "loss_offset",  :float
    t.column "link_loss",    :boolean
  end

  create_table "scheduled_sources", :force => true do |t|
    t.column "schedule_id",         :integer, :null => false
    t.column "switch_port_id",      :integer
    t.column "stat_trace_flag",     :integer, :default=>true
    t.column "integral_trace_flag", :integer, :default=>true
    t.column "order_nbr",           :integer
  end

  create_table "schedules", :force => true do |t|
    t.column "update_value",         :integer
    t.column "serial_number",        :integer
    t.column "comment",              :string,  :limit => 41, :default => "",   :null => false
    t.column "acquisition_count",    :integer, :limit => 3
    t.column "attenuator",           :integer, :limit => 3, :default=>10
    t.column "sample_time",          :integer, :limit => 5,:default=>900
    t.column "stat_trace_flag",      :boolean,               :default => true
    t.column "integral_trace_flag",  :boolean,               :default => true
    t.column "trace_polling_period", :integer, :limit => 1,  :default => 1
    t.column "analyzer_id",          :integer
  end

  create_table "sf_channels", :force => true do |t|
    t.column "channel_number",    :string,  :limit => 3
    t.column "channel_name",      :string,  :limit => 42
    t.column "channel_type",      :string,  :limit => 1
    t.column "direction",         :string,  :limit => 1
    t.column "use_full_scan",     :boolean
    t.column "use_miniscan",      :boolean
    t.column "active",            :boolean
    t.column "unit_type",         :string,  :limit => 1
    t.column "sf_system_file_id", :integer
    t.column "channel_dtls",      :text
  end

  create_table "sf_setups", :force => true do |t|
    t.column "setup_type",        :integer
    t.column "data_type",         :integer
    t.column "value",             :string,  :limit => 60
    t.column "sf_system_file_id", :integer
  end

  create_table "sf_simple_channels", :force => true do |t|
    t.column "type",              :integer, :limit => 4
    t.column "number",            :string,  :limit => 10
    t.column "name",              :string,  :limit => 42
    t.column "center_freq",       :integer
    t.column "modulation",        :integer
    t.column "sf_system_file_id", :integer
  end

  create_table "sf_system_files", :force => true do |t|
    t.column "system_name",       :string,   :limit => 42
    t.column "channel_plan_name", :string,   :limit => 42
    t.column "description",       :string,   :limit => 202
    t.column "author",            :string,   :limit => 62
    t.column "guid",              :string,   :limit => 72
    t.column "dt",                :datetime
    t.column "sf_test_plan_id",   :integer
    t.column "display_name",      :string,   :limit => 42
    t.column "status",            :string,   :limit => 1,   :default => "A"
  end

  create_table "sf_system_tests", :force => true do |t|
    t.column "test_type",       :integer
    t.column "sf_test_plan_id", :integer
    t.column "enable_flag",     :boolean
    t.column "data_type",       :integer, :limit => 4
    t.column "min_value",       :float
    t.column "max_value",       :float
    t.column "tolerance",       :float
    t.column "units",           :integer, :limit => 4
  end

  create_table "sf_test_channels", :force => true do |t|
    t.column "sf_test_plan_id", :integer
    t.column "test_type",       :integer
    t.column "enable_flag",     :boolean
    t.column "sf_channel_id",   :integer
  end

  create_table "sf_test_plans", :force => true do |t|
    t.column "name",            :string,  :limit => 42
    t.column "test_plan_ident", :string,  :limit => 2
    t.column "system_file_id",  :integer
  end

  create_table "sites", :force => true do |t|
    t.column "name",                    :string
    t.column "address",                 :string
    t.column "structure_type",          :string
    t.column "pole_pad_nbr",            :string
    t.column "rack_nbr",                :string
    t.column "rack_space",              :string
    t.column "mfg",                     :string
    t.column "device",                  :string
    t.column "signal_source_site",      :string
    t.column "media_transistion_site",  :string
    t.column "map_number",              :string
    t.column "device_type",             :string
    t.column "power_supply",            :string
    t.column "power_direction",         :string
    t.column "ac_voltage",              :string
    t.column "dc_voltage_raw",          :string
    t.column "dc_voltage_reg",          :string
    t.column "optical_input_lvl_light", :string
    t.column "optical_input_pad",       :string
    t.column "optical_input_lvl_dc",    :string
    t.column "optical_output_lvl",      :string
    t.column "forward_rf_input_lvl",    :string
    t.column "forward_rf_input_pad",    :string
    t.column "forward_rf_input_eq",     :string
    t.column "forward_rf_inter_stage",  :string
    t.column "return_rf_input_pad",     :string
    t.column "return_rf_input_eq",      :string
    t.column "safety_notes",            :text
    t.column "comments",                :text
  end

  create_table "switch_ports", :force => true do |t|
    t.column "switch_id",        :integer
    t.column "name",             :string,  :limit => 32
    t.column "port_nbr",         :integer
    t.column "stat_trace_flag",  :boolean,               :default => false, :null => false
    t.column "site_id",          :integer
    t.column "center_frequency", :float
    t.column "span",             :float
    t.column "profile_id",       :integer
  end

  add_index "switch_ports", ["switch_id", "port_nbr"], :name => "swt_prt_idx", :unique => true

  create_table "switches", :force => true do |t|
    t.column "analyzer_id",       :integer
    t.column "master_switch_src", :integer, :limit => 4
    t.column "switch_name",       :string,  :limit => 11
    t.column "port_count",        :integer, :limit => 4,  :default => 16
    t.column "switch_ident",      :integer, :limit => 4
    t.column "baud_rate",         :integer
    t.column "address",           :integer
    t.column "location",          :string
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

  def self.down
  drop_table "alarm_configs"
  drop_table "alarms"
  drop_table "analyzers"
  drop_table "channels"
  drop_table "config_params"
  drop_table "datalogs"
  drop_table "limits"
  drop_table "measurements"
  drop_table "measures"
  drop_table "profiles"
  drop_table "scheduled_sources"
  drop_table "schedules"
  drop_table "sf_channels"
  drop_table "sf_setups"
  drop_table "sf_simple_channels"
  drop_table "sf_system_files"
  drop_table "sf_system_tests"
  drop_table "sf_test_channels"
  drop_table "sf_test_plans"
  drop_table "sites"
  drop_table "switch_ports"
  drop_table "switches"
  drop_table "test_points"
  drop_table "trace_samples"
  drop_table "upstreams"
  end
end
