class IntDatalogFreq < ActiveRecord::Migration
  def self.up
    change_column("datalogs", "start_freq", :integer )
    change_column("datalogs", "stop_freq", :integer )
  end

  def self.down
    change_column("datalogs", "start_freq", :float )
    change_column("datalogs", "stop_freq", :float )
  end
end
