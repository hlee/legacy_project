class AddSiteIdx < ActiveRecord::Migration
  def self.up
		add_index "alarms", ["site_id", "event_time"], :name => "event_time_idx"
		add_column "down_alarms", "event_time", :datetime
		rename_column "down_alarms", "type","alarm_type"
		add_index "down_alarms", ["site_id", "event_time","channel_id","measure_id"], :name => "event_time_idx"
		add_column "down_alarms", "state", :string, :limit=>1
		add_column "down_alarms", "min_limit", :float
		add_column "down_alarms", "max_limit", :float
  end

  def self.down
		rename_column "down_alarms", "alarm_type","type"
    remove_column "down_alarms","event_time"
    remove_index "alarms", :name => "event_time_idx"
    remove_index "down_alarms", :name => "event_time_idx"
    remove_column "down_alarms", "state"
		remove_column "down_alarms", "min_limit"
		remove_column "down_alarms", "max_limit"
  end
end
