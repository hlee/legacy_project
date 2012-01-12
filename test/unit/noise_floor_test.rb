require File.dirname(__FILE__) + '/../test_helper'

class NoiseFloorTest < Test::Unit::TestCase
  fixtures :datalogs, :analyzers

  def test_truth
    assert true 
  end 
 
  def test_calculate_noise_floor
    dl=Datalog.find(1)
    an=Analyzer.find(6)
    nf=Datalog.cal_noise_floor(dl.image,an.id)
    assert true, nf+22.2471502859761 < 0.0001
#    puts nf.to_f/-22.2471502859761
  end
  
  def test_no_carrier
  #value is 10  
  #high threshold is 15
  #low threshold is 3
    d2=Array.new(16,10e6)
	an=Analyzer.find(6)
	nf=Datalog.cal_noise_floor(d2,an.id)
	assert_equal -999999999, nf
#    puts nf
	
    d2[10]=18*10e5
    nf=Datalog.cal_noise_floor(d2,an.id)
    assert_equal 18000000.0,nf
#    puts nf	
  end
  
end