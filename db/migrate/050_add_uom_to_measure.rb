class AddUomToMeasure < ActiveRecord::Migration
  def self.up
    add_column :measures, :uom, :string
  end

  def self.down
    remove_column :measures, :uom
  end
end
