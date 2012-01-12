require 'date'

class ServicesController < ApplicationController

  wsdl_service_name 'Services'

  web_service_api ServicesApi
  web_service_scaffold :invoke

  #######################
  # Instrument/Network configuration services
  #######################
  def get_profile_list
    profile_list=Profile.find_active_profiles
    list=[]
    profile_list.each { |prof_rec|
      pf=ProfileStruct.new
      pf.name=prof_rec.name
      pf.id=prof_rec.id
      list.push(pf)
    }
    return list
  end
  def get_profile(name)
    profile_rec=Profile.find_by_name(name, :conditions => "status is NULL")
    idx=0
    profile=[]
    start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
    freq_range=ConfigParam.get_value(ConfigParam::StopFreq) -
      ConfigParam.get_value(ConfigParam::StartFreq)
    delta=freq_range/Profile::SAMPLE_COUNT 
    profile_rec.trace.each { |point|
      point_obj=ProfilePointStruct.new()
      point_obj.val=point
      point_obj.freq=delta*idx+start_freq
      profile.push(point_obj)
      idx+=1
    }
    profile_obj=ProfileDefStruct.new()
    profile_obj.major_offset=profile_rec.major_offset
    profile_obj.minor_offset=profile_rec.minor_offset
    profile_obj.loss_offset=profile_rec.loss_offset
    profile_obj.profile=profile
    return profile_obj
  end
  def set_profile(name,trace_vals,trace_freqs,major,minor,loss)
    profile=Profile.find(:first,:conditions=>["name=? and status is NULL",name]);

    #If record does not exist then create a new one.
    if (profile.nil?) 
      profile=Profile.new()
      profile.name=name
      logger.debug "Logging Profile #{profile.name}"
    end
    trace=[]
    if (trace_vals.length !=trace_freqs.length)
      return false
    end
    profile.trace=Profile.build_trace(trace_vals,trace_freqs)
    profile.major_offset=major
    profile.minor_offset=minor
    profile.loss_offset=loss
    profile.save
    return true
  end

  def get_sites(site_type=nil)
    logger.debug "Inside Get Sites"
    if site_type==1
      sites=Site.data_sites(:downstream)
    elsif site_type==2
      sites=Site.data_sites(:upstream)
    else
      sites=Site.data_sites()
    end
    site_list=sites.collect { |site| 
      site_obj=SiteStruct.new()
      site_obj.name=site[0]
      site_obj.site_id=site[1]
      site_obj
    }
    return site_list
  end

	def get_date_range(site)
		stop_dtime=Measurement.maximum(:dt,:conditions=>["site_id=?",site])
		if stop_dtime.nil?
			return []
		end
		stop_dt=DateTime.new(stop_dtime.year, stop_dtime.month, stop_dtime.day,23,59,59)
		if stop_dt.nil?
			return []
		end
		start_dtime=Measurement.minimum(:dt,:conditions=>["site_id=?",site])
		if start_dtime.nil?
			return []
		end
		start_dt=DateTime.new(start_dtime.year, start_dtime.month, start_dtime.day)
		if start_dt.nil?
			return []
		end
		return [start_dt,stop_dt]
	end

  def get_instruments
    analyzer_list=Analyzer.find(:all) { |analyzer| }
    return analyzer_list
  end

  def get_nodes(instrument_id)
    analyzer=Analyzer.find(instrument_id)
    port_obj_list=[]
    port_list=analyzer.get_port_list
    port_list.each { |port|
      port_obj=PortStruct.new()
      port_obj.port_nbr=port[:port_nbr]
      port_obj.port_id=port[:port_id]
      port_obj.site_id=port[:site_id]
      port_obj_list.push(port_obj)
    }
    return port_obj_list
  end

  def get_datalog_range(site_id)
    dr=DatalogRangeStruct.new()
    datalog_range=Datalog.get_range(site_id)
    if (datalog_range[:min_ts].nil?)
      return nil
    end
    dr.min_freq=datalog_range[:min_freq]
    dr.max_freq=datalog_range[:max_freq]
    dr.min_ts=datalog_range[:min_ts]
    dr.max_ts=datalog_range[:max_ts]
    return dr
  end

  def get_datalog_trace(transaction_id,trace_label,site_id,start_freq, stop_freq, start_ts, stop_ts, freq_res, ts_res,
    overtime_flag=false)
    #Get Data 
    datalog=Datalog.summarize_datalogs(
      {
        :site_id=>site_id, 
        :start_ts=>Time.parse(start_ts.strftime("%c")),
        :stop_ts=>Time.parse(stop_ts.strftime("%c")),
        :start_freq=>start_freq,
        :stop_freq=>stop_freq
      },
      overtime_flag)
    logger.debug start_ts.to_s()
    datalog_list=[]
    ds=DatalogStruct.new()
    ds.trace_label=trace_label
    ds.avg=datalog[:avg]
    ds.min=datalog[:min]
    ds.max=datalog[:max]
    logger.debug "Dispalay ds.avg"
    logger.debug ds.avg
    ds.total=datalog[:total]
    logger.debug "Finished Total"
    if datalog.key?(:freq)
      ds.freq=datalog[:freq]
    else
      ds.freq=[]
    end
    if datalog.key?(:time)
      ds.time=datalog[:time]
    else
      ds.time=[]
    end
    if datalog.key?(:stdev)
      ds.stdev=datalog[:stdev]
    else
      ds.stdev=[]
    end
    ds.min_freq=datalog[:min_freq]
    ds.max_freq=datalog[:max_freq]
    ds.min_ts=datalog[:min_ts]
    ds.max_ts=datalog[:max_ts]
    ds.transaction_id=transaction_id
    logger.debug "Finished Transaction.  Now building XML"
    return ds
    #return [ds]
    #
  end
  def _gen_filter(list, attr_name)
    filter_components=list.collect { |item|
      "(#{attr_name}=#{item})"
    }
    return "("+filter_components.join(" or ")+")"
  end
  def get_recent_measurement(site_id, measureList, channelList)
    data=Measurement.get_recent(site_id, measureList, channelList)
    return_list=[]
    curr_chid=nil
    vals=[]
    meas=[]
    min_limits=[]
    max_limits=[]
    logger.debug "Looping through Data #{data.length} count"
    if data.length == 0
      meas_result=InstMeasResult.new()
      meas_result.measurements=return_list
      return meas_result
    end
    data.each { |rec|
      if curr_chid != rec.channel_id #If the channel channges.
        if (!curr_chid.nil?) #If this is not the first channel.
          #Store off the current channel
          res = InstMeasurementStruct.new()
          res.val=vals
          res.measure_id=meas
          res.channel_id=curr_chid
          res.min_limit=min_limits
          res.max_limit=max_limits
          return_list.push(res)
          vals=[]
          meas=[]
          min_limits=[]
          max_limits=[]
        end
      end
      vals.push(rec.value)
      meas.push(rec.measure_id)
      curr_chid=rec.channel_id
      min_limits.push(rec.min_limit)
      max_limits.push(rec.max_limit)
      logger.debug vals.inspect()
      measure_obj=Measure.find(rec.measure_id)
      meas_ident=measure_obj.sf_meas_ident
    }
    #For the last channel
    if !vals.nil?
      res = InstMeasurementStruct.new
      res.val=vals
      res.measure_id=meas
      res.channel_id=curr_chid
      res.min_limit=min_limits
      res.max_limit=max_limits
      return_list.push(res)
    end
    logger.debug return_list.inspect()
    meas_result=InstMeasResult.new()
    meas_result.measurements=return_list
    return meas_result
  end
  def get_instance_measurement(site_id, measureList, channelList, start_dt)
    return_list=[]
    sdt=start_dt
    sdt_s=sdt.strftime('%F %T')
    iteration=Measurement.minimum(:iteration, :conditions=>["site_id=? and dt >=? ",site_id,sdt_s])
    iter_start_dt=Measurement.minimum(:dt, :conditions=>["site_id=? and iteration =?",site_id, iteration])
    iter_stop_dt=Measurement.maximum(:dt, :conditions=>["site_id=? and iteration =?",site_id, iteration])
    filter=_gen_filter(measureList, "measurements.measure_id") + " and " + _gen_filter(channelList,"measurements.channel_id")
    sql_query="select measurements.channel_id , measurements.measure_id,dt, round(avg(value),measures.dec_places) as val, " +
      "measurements.min_limit as min_limit , measurements.max_limit as max_limit " +
      "from measures  left join measurements on (measures.id=measurements.measure_id) " +
      "where measurements.site_id=#{site_id} and iteration= \"#{iteration}\" and (#{filter}) and measurements.measure_id=measures.id " + #search params
      "group by measurements.channel_id,measurements.measure_id order by measurements.channel_id, measurements.measure_id"
    data=Measurement.find_by_sql(sql_query)
    curr_chid=nil
    vals=[]
    meas=[]
    min_limits=[]
    max_limits=[]
    logger.debug "Looping through Data #{data.length} count"
    if data.length == 0
      meas_result=InstMeasResult.new()
      meas_result.start_dt=sdt
      meas_result.stop_dt=sdt
      meas_result.measurements=return_list
      return meas_result
    end
    data.each { |rec|
      if curr_chid != rec.channel_id #If the channel channges.
        if (!curr_chid.nil?) #If this is not the first channel.
          #Store off the current channel
          res = InstMeasurementStruct.new()
          res.val=vals
          res.measure_id=meas
          res.channel_id=curr_chid
          res.min_limit=min_limits
          res.max_limit=max_limits
          return_list.push(res)
          vals=[]
          meas=[]
          min_limits=[]
          max_limits=[]
        end
      end
      vals.push(rec.val)
      meas.push(rec.measure_id)
      curr_chid=rec.channel_id
      min_limits.push(rec.min_limit)
      max_limits.push(rec.max_limit)
      logger.debug vals.inspect()
      measure_obj=Measure.find(rec.measure_id)
      meas_ident=measure_obj.sf_meas_ident
    }
    #For the last channel
    res = InstMeasurementStruct.new
    res.val=vals
    res.measure_id=meas
    res.channel_id=curr_chid
    res.min_limit=min_limits
    res.max_limit=max_limits
    return_list.push(res)
    logger.debug return_list.inspect()
    meas_result=InstMeasResult.new()
    meas_result.start_dt=iter_start_dt
    meas_result.stop_dt=iter_stop_dt
    meas_result.measurements=return_list
    return meas_result
  end
  def get_measurement(site_id, measureList, channelList, start_dt, stop_dt)
    return_list=[]
    #Get Limit Data

    #Build measurement query
    cond_str="site_id=? and measure_id=? and channel_id=? and dt between ? and ?"
    filter=_gen_filter(measureList, "measurements.measure_id") + ((channelList.length > 0) ? (" and " + _gen_filter(channelList,"measurements.channel_id")) : "")
    sql_query="select measurements.channel_id, measurements.measure_id,round(min(IFNULL(min_value,value)),measures.dec_places)as min, round(avg(value),measures.dec_places) as avg, round(max(IFNULL(max_value,value)),measures.dec_places) as max, " +
      "measurements.min_limit as min_limit , measurements.max_limit as max_limit " +
      "from measures  left join measurements on (measures.id=measurements.measure_id) " +
      "where measurements.site_id=#{site_id} and dt between \"#{start_dt}\" and \"#{stop_dt}\" and (#{filter}) and measurements.measure_id=measures.id " + #search params
      "group by measurements.channel_id,measurements.measure_id order by measurements.channel_id, measurements.measure_id"
    data=Measurement.find_by_sql(sql_query)
    curr_chid=nil
    mins=[]
    maxs=[]
    avgs=[]
    meas=[]
    min_limits=[]
    max_limits=[]
    #reorganize records chanel/measure records to be an array of arrays.
    #cells in the inner array are per measure id
    #The cells in the outer array are per channel id.
    data.each { |rec|
      if curr_chid != rec.channel_id #If the channel channges.
        if (!curr_chid.nil?) #If this is not the first channel.
          #Store off the current channel measures and restart
          res = MeasurementStruct.new()
          res.min=mins
          res.max=maxs
          res.avg=avgs
          res.measure_id=meas
          res.channel_id=curr_chid
          ch=Channel.find(curr_chid)
          if (ch.nil?)
             res.channel_freq=0
          else
             res.channel_freq=ch.channel_freq
          end
          res.min_limit=min_limits
          res.max_limit=max_limits
          return_list.push(res)
          mins=[]
          maxs=[]
          avgs=[]
          meas=[]
          min_limits=[]
          max_limits=[]
        end
      end
      mins.push(rec.min)
      maxs.push(rec.max)
      avgs.push(rec.avg)
      meas.push(rec.measure_id)
      curr_chid=rec.channel_id
      min_limits.push(rec.min_limit)
      max_limits.push(rec.max_limit)
      measure_obj=Measure.find(rec.measure_id)
      meas_ident=measure_obj.sf_meas_ident
    }
    #For the last channel
    res = MeasurementStruct.new
    res.min=mins
    res.max=maxs
    res.avg=avgs
    res.measure_id=meas
    res.channel_id=curr_chid
    logger.debug("CURR CHID #{curr_chid}")
    if !curr_chid.nil?
      ch=Channel.find(curr_chid)
      if (ch.nil?)
         res.channel_freq=0
      else
         res.channel_freq=ch.channel_freq
      end
    else
      res.channel_freq=curr_chid
    end
    res.min_limit=min_limits
    res.max_limit=max_limits
    return_list.push(res)
    return return_list
  end
  def get_sample_times(site_id, start_dt, stop_dt)
    query="select distinct dt from measurements " +
      "where measurements.site_id=#{site_id} and dt between \"#{start_dt}\" and \"#{stop_dt}\" order by dt " #search params
    meas_list=Measurement.find_by_sql(query)
    result=[]
    meas_list.each { |meas|
      result.push(meas.dt)
    }
    return result
  end
  def get_channels(site_id)
    site=Site.find(site_id)
    analyzer_id=site.analyzer.id
    channel_list=Channel.find(:all, :conditions => {:site_id=>site_id})
    channel_result=[]
    channel_list.each{ |chan|
      logger.debug(chan.inspect())
      chinfo={}
      chinfo[:id]=chan.id
      chinfo[:channel_freq]=chan.channel_freq
      chinfo[:channel_name]=chan.channel_name
      chinfo[:channel]=sprintf("%8.4f Mhz",chan.channel_freq/1_000_000)
      chinfo[:channel_type]=chan.channel_type
      channel_result.push(chinfo)
    }
    return channel_result
  end

###################
  def get_channel_info(channel_id,site_id)
    channel=Channel.find(channel_id)
    if channel.nil? #Return nil if channel not found.
      logger.error "No Channel Object found for channel id #{channel_id}."
      return nil
    end
    site=Site.find(site_id)
    if site.nil? #Return nil if site not found.
      logger.error "No site found for site id #{site_id}."
      return nil
    end
    sf_channel=nil
    if (site.analyzer.nil?)
      return nil
    end
    sf_test_plan=site.analyzer.sf_test_plan
    if sf_test_plan.nil?
      return nil
    end
    sf_system_file=sf_test_plan.sf_system_file
    if !sf_system_file.nil?
      logger.error "Getting sf_channel #{sf_system_file.inspect}, #{channel.channel_freq}"
      sf_channel=sf_system_file.find_ch_by_freq(channel.channel_freq)
      logger.error "sf_system_file is not NIL #{sf_channel.inspect()}"
    else 
      logger.error "sf_system_file is NIL"
    end

    meas_list=Measurement.find_by_sql(["select distinct measure_id as meas_id from measurements left join measures on measurements.measure_id=measures.id where site_id=? and channel_id=? and graph_flag=1",site_id, channel_id])

   
    chinfo=ChannelInfoStruct.new
    chinfo.channel_id=channel_id
    if sf_channel.nil? #If we could not find the corresponding system file. 
      chinfo.channel_nbr="UNKNOWN"
      chinfo.channel_name="UNKNOWN"
      chinfo.modulation="UNKNOWN"
    else
      chinfo.channel_nbr=sf_channel.channel_number
      chinfo.channel_name=sf_channel.channel_name
      chinfo.modulation=sf_channel.modstr()
    end
    chinfo.channel_freq=channel.channel_freq.to_f
    chinfo.meas_list=meas_list.collect { |meas| meas.meas_id}
    return chinfo
  end
  def get_meas_values(channel_id, meas_id,site_id,start_dt,stop_dt)
    result=MeasurementArrayStruct.new()
    result.meas_values=[]
    result.meas_max_values=[]
    result.meas_min_values=[]
    result.min_limits=[]
    result.max_limits=[]
    result.dates=[]
    meas=Measure.find(meas_id)
    if meas.nil?
      return nil
    end
    start_tm=start_dt.strftime(fmt="%s")
    stop_tm=stop_dt.strftime(fmt="%s")
    secs_diff=stop_tm.to_i-start_tm.to_i
    if (secs_diff <=201)
       logger.debug("divisor 1," + secs_diff.to_s)
       sec_divisor=1
    else
       sec_divisor=(secs_diff/201).ceil
       logger.debug("Divisor "+sec_divisor.to_s)
    end
    
    sql_query="select min(dt) as dt ,Round(avg(value),dec_places) as value,Round(min(min_value),dec_places)as min_value,Round(max(max_value),dec_places)as max_value,min(min_limit) as min_limit, max(max_limit) as max_limit from measurements left join measures on measure_id=measures.id where channel_id=? and measure_id=? and site_id=? and dt between ? and ? group by floor(unix_timestamp(dt)/?)";
    values=Measurement.find_by_sql(
      [sql_query, channel_id, meas_id, site_id,start_dt.strftime('%F %T'),(stop_dt+1).strftime('%F %T'), sec_divisor])
    values.each { |rec|
      result.meas_values.push(rec.value)
      result.meas_max_values.push(rec.max_value)
      result.meas_min_values.push(rec.min_value)
      result.dates.push(rec.dt)
      result.min_limits.push(rec.min_limit)
      result.max_limits.push(rec.max_limit)
    }
    meas=Measure.find(meas_id)
    if meas.nil?
      result.measure_name="UNKNOWN MEASURE"
    else
      result.measure_name=meas.measure_label
    end
    result.measure_id=meas_id
    result.channel_id=channel_id
    result.site_id=site_id
    result.exp_flag=meas.exp_flag
    return result
  end
  def get_slm_summary(site_id, channel_list,start_dt, stop_dt)
   
    #channel_list=Channel.find(:all, :order => "channel_freq").collect { |ch| ch.id}
    #puts channel_list.inspect()
    if start_dt.nil?
      start_dt=Measurement.min(dt).strftime('%F %T')
    end
    if stop_dt.nil?
      stop_dt=Measurement.min(dt).strftime('%F %T')
    end
    measure_list=[9,11,17]
    return get_measurement(site_id, measure_list, channel_list, start_dt, stop_dt)
  end
  def get_measures
    measure_list=Measure.find(:all)
    return measure_list
  end
end
