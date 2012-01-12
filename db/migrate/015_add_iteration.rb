class AddIteration < ActiveRecord::Migration
  def self.up
    add_column "measurements", "iteration", :integer
  end

  def self.down
    remove_column "measurements", "iteration"
  end
end
