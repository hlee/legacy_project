require File.dirname(__FILE__) + '/../test_helper'

require 'image_functions'

class Dummy
  extend ImageFunctions
  include ImageFunctions
end

class ImageFuncTest < Test::Unit::TestCase

  def test_map_data
     input_data=[5.0,7.0,9.0,11.0,13.0,15.0]
     #Map to equivalent
     mapped_data=Dummy.map_data(5,15,5,15,input_data,6)
     expected_data=[5.0,7.0,9.0,11.0,13.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to equivalent"
     #Map to higher detail
     mapped_data=Dummy.map_data(5,15,5,15,input_data,11)
     expected_data=[5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to higher detail"
     #Map to lower detail
     mapped_data=Dummy.map_data(5,15,5,15,[5,7,9,11,13,15,17],4)
     expected_data=[5.0,9.0,13.0,17.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to lower detail"
     #Map equivalent to left
     mapped_data=Dummy.map_data(5,15,3,13,input_data,6)
     expected_data=[5.0,5.0,7.0,9.0,11.0,13.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the left"
     #Map equivalent to right
     mapped_data=Dummy.map_data(5,15,7,17,input_data,6)
     expected_data=[7.0,9.0,11.0,13.0,15.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the right"
     #Map from 2point to multipoint
     mapped_data=Dummy.map_data(5,15,5,15,[5,15],11)
     expected_data=[5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to higher detail"
     #Extend past boundries
     mapped_data=Dummy.map_data(5,15,3,17,input_data,8)
     expected_data=[5.0,5.0,7.0,9.0,11.0,13.0,15.0,15.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the right"
     #Non Linear Data
     input_data=[5.0,6.0,5.0,1.0,0.0,5.0]
     #Map to equivalent
     mapped_data=Dummy.map_data(5,15,5,15,input_data,6)
     expected_data=input_data
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to equivalent"
     #Map to higher detail
     mapped_data=Dummy.map_data(5,15,5,15,input_data,11)
     expected_data=[5.0,5.5,6.0,5.5,5.0,3.0,1.0,0.5,0.0,2.5,5.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to higher detail"
     #Leverage default value
     input_data=[5.0,7.0,9.0,11.0,13.0,15.0]
     mapped_data=Dummy.map_data(5,15,3,17,input_data,8,1.0)
     expected_data=[1.0,5.0,7.0,9.0,11.0,13.0,15.0,1.0]
     assert_operator mapped_data , :eql?, expected_data, "Data did not map to the right"
  end

end
