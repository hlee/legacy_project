class AddExponentialFlag < ActiveRecord::Migration
  def self.up
    add_column "measures", "exp_flag", :boolean, :default => false
    require 'rake'
  end

  def self.down
    remove_column "measures", "exp_flag"
  end
end
