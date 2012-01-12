class AddSfMeasid < ActiveRecord::Migration
  def self.up
     add_column "measures", "sf_meas_ident", :integer
  end

  def self.down
     remove_column "measures", "sf_meas_ident"
  end
end
