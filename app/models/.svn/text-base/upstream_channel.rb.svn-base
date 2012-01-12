class UpstreamChannel < ActiveRecord::Base
  validates_numericality_of :freq, :greater_than_or_equal_to => 0, :allow_nil =>false, :only_integer => true, :less_than => 1500000001
  validates_numericality_of :bandwidth, :less_than => 100000000, :allow_nil =>false, :only_integer => true, :greater_than_or_equal_to => 1000000
  def freq_disp=(x)
     write_attribute(:freq,(x.to_f*1_000_000).to_i)
  end
  def bandwidth_disp=(x)
     write_attribute(:bandwidth,(x.to_f*1_000_000).to_i)
  end
  def freq_disp()
    if freq.nil?
      return nil
    else
      return read_attribute(:freq)/1000000.0
    end
  end
  def bandwidth_disp()
    if bandwidth.nil?
      return nil
    else
      return read_attribute(:bandwidth)/1000000.0
    end
  end
end
