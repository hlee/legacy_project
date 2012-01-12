class CfgChannel < ActiveRecord::Base
   belongs_to :analyzer
   has_many :cfg_channel_tests, :dependent => :destroy
   def get_channel_type()
     if modulation.to_i >= 100
       return 'Analog'
     else
       return 'Digital'
     end
   end
end
