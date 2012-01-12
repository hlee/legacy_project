module Sunrise
   HZ=1
   KHZ=1000
   MHZ=1000000
   class Properties
      include Singleton
      MIN_MONITORING_FREQ=          0
      MAX_MONITORING_FREQ=  135000000
      MIN_DATA_LOGGING_FREQ=  5000000
      MAX_DATA_LOGGING_FREQ= 45000000
      def minMonitoringFreq(divider=1)
         return MIN_MONITORING_FREQ/divider
      end
      def maxMonitoringFreq(divider=1)
         return MAX_MONITORING_FREQ/divider
      end
      def minDataLoggingFreq(divider=1)
         return MIN_DATA_LOGGING_FREQ/divider
      end
      def maxDataLoggingFreq(divider=1)
         return MAX_DATA_LOGGING_FREQ/divider
      end
   end
end
