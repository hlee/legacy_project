class MeasuresAddDigitalFlag < ActiveRecord::Migration
  def self.up
    add_column "measures", "digital_flag", :boolean, :default => true
  end

  def self.down
    remove_column "measures", "digital_flag"
  end
end
