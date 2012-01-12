require File.dirname(__FILE__) + '/../test_helper'

class ConfigParamTest < Test::Unit::TestCase
  fixtures :config_params

  def setup
  end

  def test_number_of_config_params
    assert_equal 41, ConfigParam.count, "Should be 41 ConfigParams, but the db shows #{ConfigParam.count}"
  end

  def test_config_params_cant_be_deleted
    param = ConfigParam.find(:first)
    count_before = ConfigParam.count
    assert_raise(RuntimeError){ param.destroy }
    count_after = ConfigParam.count
    assert_equal count_before, count_after
  end

  def test_config_params_unique_name
    param1 = ConfigParam.find(:all).first
    param2 = ConfigParam.find(:all).last
    assert_not_equal param1.id, param2.id

    param2.name = param1.name
    assert !param2.valid?
    assert param2.errors.invalid?(:name)
    assert_equal "has already been taken", param2.errors.on(:name)
  end
  def test_config_params_inclusion_of
    param1 = ConfigParam.find(:all).first
    param1.ident = 150;
    assert !param1.valid?
    assert param1.errors.invalid?(:ident)
    assert_equal "is not included in the list", param1.errors.on(:ident)
  end
  def test_config_params_val_not_null
    param1 = ConfigParam.find(:all).first
    param1.val = '';
    assert !param1.valid?
    assert param1.errors.invalid?(:val)
    assert_equal "can't be blank", param1.errors.on(:val)

    param1.val = nil;
    assert !param1.valid?
    assert param1.errors.invalid?(:val)
    assert_equal "can't be blank", param1.errors.on(:val)
  end
  def test_config_params_data_type
    param1 = ConfigParam.find(:all).first
    param1.data_type = 5;
    assert !param1.valid?, "#{param1.data_type} should not be a valid setting for the data_type field"
    assert param1.errors.invalid?(:data_type)
    assert_equal "is not included in the list", param1.errors.on(:data_type)
  end
  def test_config_params_size
    param1 = ConfigParam.find(:all).first
    param1.size = "blah";
    assert !param1.valid?, "#{param1.size} should have to be an integer"
    assert param1.errors.invalid?(:size)
    assert_equal "is not a number", param1.errors.on(:size)
    param1.size = 50;
    param1.valid?
    assert !param1.errors.invalid?(:size), "#{param1.size} is a valid integer"
  end
  def test_config_params_description
    param1 = ConfigParam.find(:all).first

    param1.descr = "Short";
    assert !param1.valid?, "#{param1.descr} should be too short for ConfigParams description"
    assert param1.errors.invalid?(:descr)
    assert_equal "is too short (minimum is 10 characters)", param1.errors.on(:descr)

    param1.descr = "a"*256
    assert !param1.valid?, "#{param1.descr} should be too long for ConfigParams description"
    assert param1.errors.invalid?(:descr)
    assert_equal "is too long (maximum is 255 characters)", param1.errors.on(:descr)

    param1.descr = "This description is just right";
    param1.valid? # Force validation to run
    assert !param1.errors.invalid?(:descr), "Blank uom should be a valid ConfigParams uom"
    assert_nil param1.errors.on(:descr)
  end
  def test_config_params_category
    param1 = ConfigParam.find(:all).first

    param1.category = 'INVALID'
    assert !param1.valid?, "#{param1.category} is not a valid ConfigParams category"
    assert param1.errors.invalid?(:category)
    assert_equal "must be one of ", param1.errors.on(:category)

    param1.category = 'ANALYZER SETTING'
    assert param1.valid?, "#{param1.category} is a valid ConfigParams category"
    assert !param1.errors.invalid?(:category)
    assert_nil param1.errors.on(:category)
  end
  def test_config_params_category
    param1 = ConfigParam.find(:all).first

    param1.uom = 'sec'
    assert !param1.valid?, "#{param1.uom} is not a valid ConfigParams uom"
    assert param1.errors.invalid?(:uom)
    assert_equal "should be milliseconds, Mhz or blank", param1.errors.on(:uom)
    param1.uom = 'Mhz'
    param1.valid? #Force the validation to run again.
    assert !param1.errors.invalid?(:uom)
    assert_nil param1.errors.on(:uom)

    param1.uom = 'MHZ'
    assert !param1.valid?, "#{param1.uom} is not a valid ConfigParams uom"
    assert param1.errors.invalid?(:uom)
    assert_equal "should be milliseconds, Mhz or blank", param1.errors.on(:uom)

    param1.uom = ''
    param1.valid? #Run the validation
    assert !param1.errors.invalid?(:uom), "Blank uom should be a valid ConfigParams uom"
    assert_nil param1.errors.on(:uom)
  end
  def test_config_params_validate_get_value
    ConfigParam.find(:all).each {|param|
      value = ""
      assert_nothing_raised(RuntimeError){ value = ConfigParam.get_value(param.name) }
      assert_not_nil value, "value returned from ConfigParam.get_value(#{param.name}) should not be null"
      if(param.data_type == 1)
        assert_instance_of(Fixnum, value)
        assert_equal param.val.to_i, value
      elsif(param.data_type == 2)
        if param.uom == 'Mhz'
           assert_instance_of(Float, value)
           assert_equal param.val.to_f*1000000, value
        else
           assert_instance_of(Float, value)
           assert_equal param.val.to_f, value
        end
      elsif(param.data_type == 3)
        assert_instance_of(String, value)
        assert_equal param.val.to_s, value
      else
        # Should never get here, as an exception would be raised
        # when trying to run ConfigParam.get_value.
      end
    }

    assert_raise(RuntimeError){ value = ConfigParam.get_value('123451234512345') }
  end
  def test_config_params_save_deletes_cache
    Datalog.delete_all()
    param = ConfigParam.get_value("Start Frequency")
    param2 = ConfigParam.find_by_name("Start Frequency")
    
    assert_equal param, param2.val.to_f*1000000.0
    # Change the db and make sure future calls to get_value get the updated
    # version, not keeping the cache
    
    param2.uom="Mhz"
    param2.val = (param2.val.to_i * 2).to_f
    Analyzer.update_all("status=10")
    assert param2.save, "ERROR:  Unable to save param2 #{param2.val} (ERROR: #{param2.errors.full_messages})"
    param3 = ConfigParam.get_value("Start Frequency")
    #TODO fix test. Never have upderstood Jason Noble's caching mechanism. disabling test for now.
    assert_not_equal param, param3, " cached version should be updated, but wasn't."
    assert_equal param * 2 , param3, " cached version should be updated, but wasn't."
    param2.val = param2.val.to_i / 2
    assert param2.save, "ERROR:  Unable to save param2 #{param2.val} (ERROR: #{param2.errors.full_messages})"
  end
  def test_snmp_counter
    x=ConfigParam.increment("SNMP Sequence Counter")
    y=ConfigParam.increment("SNMP Sequence Counter")
    assert_equal x+1,y,"Increment failed"
  end
end
