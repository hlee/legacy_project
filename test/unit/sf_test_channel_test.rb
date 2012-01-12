require File.dirname(__FILE__) + '/../test_helper'

class SfTestChannelTest < Test::Unit::TestCase
  fixtures :sf_test_channels

  def test_unique_sf_channel_id
    sf_test_channel1 = SfTestChannel.find(1)
    sf_test_channel2 = SfTestChannel.find(2)
    assert_not_equal sf_test_channel1.id, sf_test_channel2.id

    sf_test_channel2.sf_channel_id = sf_test_channel1.sf_channel_id
    assert !sf_test_channel2.valid?
    assert sf_test_channel2.errors.invalid?(:sf_channel_id)
    assert_equal "has already been taken", sf_test_channel2.errors.on(:sf_channel_id)
  end
end
