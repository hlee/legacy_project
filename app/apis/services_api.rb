class PortStruct < ActionWebService::Struct
  member :port_nbr, :string
  member :port_id, :int
  member :site_id, :int
end

class SiteStruct < ActionWebService::Struct
  member :name, :string
  member :site_id, :int
end

class DatalogStruct < ActionWebService::Struct
  member :transaction_id, :int
  member :trace_label, :string
  member :avg, [:int]
  member :min, [:int]
  member :total, [:int]
  member :time, [:datetime]
  member :max, [:int]
  member :freq, [:int]
  member :min_freq, :int
  member :max_freq, :int
  member :min_ts, :datetime
  member :max_ts, :datetime
  member :stdev, [:float]
end
#class ChannelInfoStruct < ActionWebService::Struct
#  member :channel_id, :string
#  member :channel_name, :string
#  member :channel_freq, :string
#
#end

class UserIPStruct < ActionWebService::Struct
  member :user, :string
  member :ip, :string
end
class DatalogRangeStruct < ActionWebService::Struct
  member :min_freq, :int
  member :max_freq, :int
  member :min_ts, :datetime
  member :max_ts, :datetime
end
class ProfilePointStruct < ActionWebService::Struct
  member :val, :float
  member :freq, :float
end
class ProfileDefStruct < ActionWebService::Struct
  member :val, :float
  member :freq, :float
	member :major_offset, :float
	member :minor_offset, :float
	member :loss_offset, :float
	member :profile, [ProfilePointStruct]
end
class ProfileStruct < ActionWebService::Struct
  member :id, :int
  member :name, :string
end

class InstMeasurementStruct < ActionWebService::Struct
  member :channel_id, :int
  member :measure_id, [:int]
  member :val, [:float]
  member :min_limit, [:float]
  member :max_limit, [:float]
end
class InstMeasResult < ActionWebService::Struct
  member :start_dt,:datetime
  member :stop_dt,:datetime
  member :measurements,[InstMeasurementStruct]
end

class MeasurementStruct < ActionWebService::Struct
  member :channel_id, :int
  member :measure_id, [:int]
  member :channel_freq, :float
  member :avg, [:float]
  member :min, [:float]
  member :max, [:float]
  member :min_limit, [:float]
  member :max_limit, [:float]
end

class ChannelInfoStruct < ActionWebService::Struct
  member :channel_id, :int
  member :channel_nbr, :string
  member :channel_name, :string
  member :channel_freq, :int
  member :modulation, :string
  member :meas_list, [:int]
end

class ChannelShortStruct < ActionWebService::Struct
  member :id, :int #This is the id stored in the channels tables
  member :channel, :string
  member :channel_name, :string
  member :channel_freq, :int
  member :modulation, :string
  member :channel_type, :string
end

class MeasurementArrayStruct < ActionWebService::Struct
  member :measure_id, :int
  member :measure_name, :string
  member :site_id, :int
  member :channel_id, :int
  member :exp_flag,:bool
  member :meas_values, [:float]
  member :meas_max_values, [:float]
  member :meas_min_values, [:float]
  member :min_limits, [:float]
  member :max_limits, [:float]
  member :dates, [:datetime]
end

class ConstellationStruct < ActionWebService::Struct
  member :matrix,[[:float]]
end

class ServicesApi < ActionWebService::API::Base
  api_method :get_sample_times ,:expects=>[:int, :string, :string], :returns => [[:datetime]]
  api_method :get_sites, :expects=>[:int],:returns=>[[SiteStruct]]
  api_method :get_instruments , :returns => [[Analyzer]]
  api_method :get_nodes, :expects =>[:int], :returns => [[PortStruct]]
  api_method :get_datalog_trace, :expects =>[:int,:string,:int,:int, :int, :datetime,:datetime,:int,:int,:bool], :returns => [DatalogStruct]
  api_method :get_datalog_range, :expects=>[:int], :returns => [DatalogRangeStruct]
  api_method :get_profile_list,:returns=>[[ProfileStruct]]
  api_method :get_profile,:expects=>[:string],:returns=>[ProfileDefStruct]
  api_method :set_profile,:expects=>[:string,[:float],[:float],
     :float,:float,:float],:returns=>[:bool]
  api_method :get_measurement, :expects=>[:string,[:string],[:string],:string,:string],:returns=>[[MeasurementStruct]]
  api_method :get_recent_measurement, :expects=>[:string,[:string],[:string]],:returns=>[InstMeasResult]
  api_method :get_slm_summary, :expects=>[:string,[:string],:string,:string],:returns=>[[MeasurementStruct]]
  #api_method :get_instance_measurement, :expects=>[:string,[:string],[:string],:datetime],:returns=>[InstMeasResult]
  api_method :get_channels, :expects=>[:int],:returns=> [[ChannelShortStruct]]
  api_method :get_measures, :returns=> [[Measure]]
  api_method :get_date_range,:expects=>[:int], :returns=> [[:datetime]]
  api_method :get_channel_info,:expects=>[:int,:int], :returns=> [ChannelInfoStruct]
  #EXPECTS channel_id, measure_id, site_id, start_date, stop_date
  api_method :get_meas_values,:expects=>[:int,:int,:int,:datetime, :datetime], :returns=> [MeasurementArrayStruct]
  api_method :get_constellation,:expects=>[:int,:int,:datetime,:datetime],:returns=>[[ConstellationStruct]]
  api_method :get_uom,:returns=>[:int]
end
