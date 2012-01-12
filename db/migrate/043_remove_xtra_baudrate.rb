class RemoveXtraBaudrate < ActiveRecord::Migration
  def self.up
    remove_column :switches, :baud_rate
  end

  def self.down
    add_column :switches, "baud_rate",         :integer
  end
end
