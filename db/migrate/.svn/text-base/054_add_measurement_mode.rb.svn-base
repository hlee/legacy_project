class AddMeasurementMode < ActiveRecord::Migration
  def self.up
    add_column :measures, :measurement_mode, :string, :default=>"ANALOG"
  end

  def self.down
    remove_column :measures, :measurement_mode
  end
end
