class AddActiveFlag < ActiveRecord::Migration
  def self.up
    remove_column "alarms", "state"
    remove_column "down_alarms", "state"
    add_column "alarms", "active", :boolean
    add_column "down_alarms", "active", :boolean
    add_column "alarms", "acknowledged", :boolean
    add_column "down_alarms", "acknowledged", :boolean
  end

  def self.down
    remove_column "alarms", "active"
    remove_column "down_alarms", "active"
    remove_column "alarms", "acknowledged"
    remove_column "down_alarms", "acknowledged"
    add_column "alarms", "state", :boolean
    add_column "down_alarms", "state", :boolean
  end
end
