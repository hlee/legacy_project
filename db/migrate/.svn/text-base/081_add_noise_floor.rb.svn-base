class AddNoiseFloor < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :nf_start_freq, :int, :default => 15*10e5
	add_column :analyzers, :nf_stop_freq, :int, :default => 38*10e5
	add_column :analyzers, :nf_low, :int, :default => 3*10e5
	add_column :analyzers, :nf_high, :int, :default => 15*10e5
	add_column :datalogs, :noise_floor, :float
	
	Analyzer.find(:all).each { |a|
      a.nf_start_freq=15*10e5
	  a.nf_stop_freq=38*10e5
	  a.nf_low=3*10e5
	  a.nf_high=15*10e5
      a.save
    }
  end
  
  def self.down
    remove_column :analyzers, :nf_start_freq
    remove_column :analyzers, :nf_stop_freq
    remove_column :analyzers, :nf_low
    remove_column :analyzers, :nf_high
	remove_column :datalogs,  :noise_floor
  end
end