class RemoveSfFromSite < ActiveRecord::Migration
  def self.up
    remove_column "sites", "sf_system_file_id"
    add_index "measurements", ["site_id","measure_id","channel_id", "value"],:name => "meas_val_idx"
  end

  def self.down
    add_column "sites", "sf_system_file_id", :integer
    remove_index "measurements",:name => "meas_val_idx"
  end
end
