class SumFldsMeasures < ActiveRecord::Migration
  def self.up
    add_column "measurements", "min_value", :float
    add_column "measurements", "max_value", :float
    add_column "measurements", "sum_count", :integer
  end

  def self.down
    remove_column "measurements", "min_value"
    remove_column "measurements", "max_value"
    remove_column "measurements", "sum_count"
  end
end
