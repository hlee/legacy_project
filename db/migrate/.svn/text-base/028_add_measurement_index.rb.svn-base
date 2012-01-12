class AddMeasurementIndex < ActiveRecord::Migration
  def self.up
    add_index "measurements", ["site_id","measure_id","channel_id", "dt"],:name => "meas_idx"
    add_column "measures", "graph_flag", :boolean, :default => true
  end

  def self.down
    remove_index "measurements",:name => "meas_idx"
    remove_column "measures", "graph_flag"
  end
end
