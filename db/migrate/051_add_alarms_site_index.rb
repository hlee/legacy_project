class AddAlarmsSiteIndex < ActiveRecord::Migration
  def self.up
    add_index "alarms", ["site_id", "active"], :name => "site_id_active_idx"
  end

  def self.down
    remove_index "alarms", :name => "site_id_active_idx"
  end
end
