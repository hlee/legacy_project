class LimitFlagMeasures < ActiveRecord::Migration
  def self.up
    add_column "measures", "check_min_flag", :boolean, :default => true
    add_column "measures", "check_max_flag", :boolean, :default => true
    add_column "measures", "sanity_max", :float
    add_column "measures", "sanity_min", :float
  end

  def self.down
    remove_column "measures","check_min_flag"
    remove_column "measures","check_max_flag"
    remove_column "measures","sanity_max"
    remove_column "measures","sanity_min"
  end
end
