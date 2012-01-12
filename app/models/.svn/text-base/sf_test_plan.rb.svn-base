class SfTestPlan < ActiveRecord::Base
  belongs_to :sf_system_file
  has_many :sf_system_tests, :dependent => :destroy
  has_many :sf_test_channels, :dependent => :destroy

  def find_test(test_type)
    results=sf_system_tests.find(:all, :conditions=>["test_type =?",test_type])
    return results
  end
  def <=>(other)
    self.name <=> other.name
  end

  def need_mode(mode)
    if (mode != "ANALOG") && (mode != "DCP") && (mode!="QAM")
      raise "#{mode} not a recognized measurement mode"
    end
    sf_system_tests.each { |system_test|
      if (system_test.enable_flag==true)
      system_test.measure.each { |measure|
        if (measure.measurement_mode == mode)
          return true
        end
      }
      end
    }
    return false
  
  end
end
