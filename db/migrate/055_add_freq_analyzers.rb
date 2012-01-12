class AddFreqAnalyzers < ActiveRecord::Migration
  def self.up
    add_column :analyzers, :start_freq, :int
    add_column :analyzers, :stop_freq, :int
    startFreq=ConfigParam.get_value(ConfigParam::StartFreq);
    stopFreq=ConfigParam.get_value(ConfigParam::StopFreq);
    puts startFreq
    puts stopFreq
    Analyzer.find(:all).each { |a|
      a.start_freq=startFreq;
      a.stop_freq = stopFreq;
      a.save
    }
    1;
  end

  def self.down
    remove_column :analyzers, :start_freq
    remove_column :analyzers, :stop_freq
  end
end
