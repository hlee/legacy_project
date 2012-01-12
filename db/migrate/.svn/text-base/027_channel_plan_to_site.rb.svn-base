class ChannelPlanToSite < ActiveRecord::Migration
  def self.up
    add_column "sites", "sf_system_file_id", :integer
    change_column "alarms", "alarm_type", :integer,:default=>1
  end

  def self.down
    remove_column "sites", "sf_system_file_id"
    change_column "alarms", "alarm_type", :string,:limit=>1,:default=>"I"
  end
end
