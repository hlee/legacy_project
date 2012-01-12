#require "ar-extensions"
class RangeNotSet < RuntimeError
end
class Datalog < ActiveRecord::Base 
  belongs_to :site
  SAMPLE_SIZE=500
  extend ImageFunctions
  include ImageFunctions
  #   has_many :datalog_dtls, :order => :freq, :dependent => :destroy

  def image=(data)
    write_image(:image, data)
  end
  def image()
    result=read_image(:image)
    return result
  end
  def min_image=(data)
    write_image(:min_image,data)
  end
  def min_image()
    return read_image(:min_image)
  end
  def max_image=(data)
    write_image(:max_image,data)
  end
  def max_image()
    return read_image(:max_image)
  end
  def validate
    #errors.add("image","Invalid image size") unless @image.length==500
    #errors.add("max_image","Invalid image size") unless @max_image.length==500
    #errors.add("min_image","Invalid image size") unless @min_image.length==500
  end
  def store_images(min_trace, trace,max_trace)
    #After we save datalog then we build the corresponding detail recs
    if min_trace.length != SAMPLE_SIZE
      raise "min image is wrong size #{min_trace.length}"
    end
    if max_trace.length != SAMPLE_SIZE
      raise "max image is wrong size #{max_trace.length}"
    end
    if trace.length != SAMPLE_SIZE
      raise "image is wrong size #{trace.length}"
    end
    bw=stop_freq-start_freq
    dtls=[]
    self.max_image=max_trace
    self.min_image=min_trace
    self.image=trace
    self.max_val=max_trace.max
    self.min_val=min_trace.min
    self.val=trace.sum/trace.length
    self.save
  end
  def Datalog::get_range(site_id)
    cond_str="site_id=#{site_id}"
    max_ts=maximum('ts',:conditions=>cond_str)
    min_ts=minimum('ts',:conditions=>cond_str)
    max_freq=maximum('stop_freq',:conditions=>cond_str)
    min_freq=minimum('start_freq',:conditions=>cond_str)
    if (max_freq.nil?)
      max_freq=ConfigParam.get_value("Stop Frequency")
      min_freq=ConfigParam.get_value("Start Frequency")
    end
    return {:max_ts=>max_ts,
      :min_ts=>min_ts,
      :max_freq=>max_freq,
      :min_freq=>min_freq}
  end
  def Datalog::summarize_datalogs(filter_params, over_time=true)
    raise RangeNotSet, 'Site required'        unless filter_params.key?(:site_id) 
    raise RangeNotSet, 'start ts required'    unless filter_params.key?(:start_ts) 
    raise RangeNotSet, 'stop ts required'     unless filter_params.key?(:stop_ts) 
    raise RangeNotSet, 'start freq required'  unless filter_params.key?(:start_freq) 
    raise RangeNotSet, 'stop freq required'   unless filter_params.key?(:stop_freq) 
    #Test for nils
    raise RangeNotSet, 'Site nil'             unless !filter_params[:site_id].nil?
    raise RangeNotSet, 'start ts nil'         unless !filter_params[:start_ts].nil?
    raise RangeNotSet, 'stop ts nil'          unless !filter_params[:stop_ts].nil?
    raise RangeNotSet, 'start freq nil'       unless !filter_params[:start_freq].nil?
    raise RangeNotSet, 'stop freq nil'        unless !filter_params[:stop_freq].nil?
    logger.debug "Inside summarize Datalogs"
    #Build filter
    ##################################################################
    cond_params={}
    cond_params[:site_id]=filter_params[:site_id]
    logger.debug filter_params[:start_ts].class.to_s
    if filter_params[:start_ts].kind_of?(String)
      cond_params[:start_ts]=filter_params[:start_ts]
    elsif filter_params[:start_ts].kind_of?(Time)
      cond_params[:start_ts]=filter_params[:start_ts].strftime("%Y-%m-%d %H:%M:%S")
    elsif filter_params[:start_ts].kind_of?(Numeric)
      cond_params[:start_ts]=Time.at(filter_params[:start_ts]).strftime("%Y-%m-%d %H:%M:%S")
    else
      raise "Unable to recognize time"
    end
    if filter_params[:stop_ts].kind_of?(String)
      cond_params[:stop_ts]=filter_params[:start_ts]
    elsif filter_params[:stop_ts].kind_of?(Time)
      cond_params[:stop_ts]=filter_params[:stop_ts].strftime("%Y-%m-%d %H:%M:%S")
    elsif filter_params[:stop_ts].kind_of?(Numeric)
      cond_params[:stop_ts]=Time.at(filter_params[:stop_ts]).strftime("%Y-%m-%d %H:%M:%S")
    else
      raise "Unable to recognize"
    end
    cond_params[:start_freq]=[filter_params[:start_freq],ConfigParam.get_value(ConfigParam::StartFreq)].max
    cond_params[:stop_freq]=[filter_params[:stop_freq],ConfigParam.get_value(ConfigParam::StopFreq)].min
    cnd_str="start_freq  <= :stop_freq and stop_freq >= :start_freq " +
      "and ts >= :start_ts and ts < :stop_ts and site_id=:site_id"
    collection={:min=>nil,:max=>nil,:total=>nil,:freq=>nil}
    if (cond_params[:stop_freq] < ConfigParam.get_value("Start Frequency"))
      collection[:min]=[]
      collection[:max]=[]
      collection[:total]=[]
      collection[:avg]=[]
      return collection
    end
    if (cond_params[:start_freq] > ConfigParam.get_value("Stop Frequency"))
      collection[:min]=[]
      collection[:max]=[]
      collection[:total]=[]
      collection[:avg]=[]
      return collection
    end
    time_list=[]
    if (!over_time) #x-axis is over frequency range
      #AVG TRACE
      query_str= "select " +
      "avgarray(image,500,start_freq,stop_freq, 500,?,? ) as trace, " +
      "maxarray(max_image,500,start_freq,stop_freq,500,?,?) as max_trace, " +
      "minarray(min_image,500,start_freq,stop_freq,500,?,?) as min_trace, " +
      "min(start_freq) as min_start_freq,max(stop_freq) as max_stop_freq " +
      "from datalogs where " +
      "site_id=? and " +
      "ts >= ? and ts <= ?"
      datalogs=find_by_sql([query_str,
        cond_params[:start_freq].to_i,cond_params[:stop_freq].to_i,
        cond_params[:start_freq].to_i,cond_params[:stop_freq].to_i,
        cond_params[:start_freq].to_i,cond_params[:stop_freq].to_i,
        cond_params[:site_id],cond_params[:start_ts],
        cond_params[:stop_ts]])
      if datalogs[0].trace.nil?
        image=[]
        logger.debug "FAILED TRACE" + query_str
      else
        image=datalogs[0].trace.unpack("e500")
        logger.debug "TRACE--- #{image.inspect()}"
      end
      if datalogs[0].min_trace.nil?
        min_image=[]
        logger.debug "FAILED MIN TRACE" + query_str
      else
        min_image=datalogs[0].min_trace.unpack("e*")
      end
      if datalogs[0].max_trace.nil?
        max_image=[]
        logger.debug "FAILED MAX TRACE" + query_str
      else
        max_image=datalogs[0].max_trace.unpack("e*")
      end
      logger.debug cnd_str
      logger.debug cond_params.inspect()
      if (datalogs.length == 0)
        collection[:min]=[]
        collection[:max]=[]
        collection[:total]=[]
        collection[:avg]=[]
        collection[:time]=[]
        collection[:freq]=[]
        return collection
      end
      min_freq= cond_params[:start_freq].to_i
      max_freq= cond_params[:stop_freq].to_i
      freq_interval=(max_freq-min_freq)/(SAMPLE_SIZE-1)
      
      logger.debug "Freq Interval #{freq_interval}"
      #ts_interval=nil
      ##Build Datasets
      #collection_count=0
      #start_cell=((cond_params[:start_freq].to_f-ConfigParam.get_value("Start Frequency").to_f) /
      #  stored_interval.to_f).ceil()
      #stop_cell=(((cond_params[:stop_freq].to_f-
      #  ConfigParam.get_value("Start Frequency").to_f)/
      #  stored_interval.to_f)+0.001).floor()
      start_cell=0
      stop_cell=499
      collection[:min]=min_image[start_cell..stop_cell]
      collection[:max]=max_image[start_cell..stop_cell]
      collection[:total]=image[start_cell..stop_cell]
      collection[:avg]=image[start_cell..stop_cell]
      collection[:freq]=Array.new()
      collection[:stdev]=image[start_cell..stop_cell]
      len=collection[:avg].length
      start_cell.upto(stop_cell){|cell|
        #Add 0.5 and then .to_i will round freq
        freq=(freq_interval*cell+min_freq+0.5).to_i
        collection[:freq].push(freq)
      }
      logger.debug "Freq List #{collection[:freq].inspect()}"
      collection[:min_freq]=collection[:freq].min
      collection[:max_freq]=collection[:freq].max
    else #x-axis is over time
      logger.debug("OVERTIME ")
      logger.debug(cond_params.inspect())
      stop_ts_secs=Time.parse(cond_params[:stop_ts]).strftime(fmt="%s")
      logger.debug(stop_ts_secs)
      start_ts_secs=Time.parse(cond_params[:start_ts]).strftime(fmt="%s")
      logger.debug(start_ts_secs)
      secs_diff= stop_ts_secs.to_i - start_ts_secs.to_i
      logger.debug(secs_diff)
      logger.debug("----------------")
      secs_divisor=1
      if secs_diff > 201
        sec_divisor=(secs_diff/201).ceil
      end
      datalogs=find_by_sql([
        "select max_val, min_val, val,ts " +
        "from datalogs where " +
        "site_id=? and " +
        "ts >= ? and ts <= ? group by floor(unix_timestamp(ts)/?)",
        cond_params[:site_id],cond_params[:start_ts],
        cond_params[:stop_ts],secs_divisor])
      logger.debug cnd_str
      logger.debug cond_params.inspect()
      logger.debug "Datalog Count #{datalogs.length}"
      if (datalogs.length == 0)
        collection[:min]=[]
        collection[:max]=[]
        collection[:total]=[]
        collection[:avg]=[]
        collection[:time]=[]
        collection[:avg]=[]
        return collection
      end
      collection={:min=>[],:max=>[],:avg=>[],:total=>[],:time=>[]}
      datalogs.each { |rec|
        collection[:min].push(rec.min_val.to_f)
        collection[:max].push(rec.max_val.to_f)
        collection[:avg].push(rec.val.to_f)
        collection[:time].push(rec.ts)
        time_list.push(rec.ts)
      }
      #collection=compress_overtime(collection,500)
      collection[:min_freq]=ConfigParam.get_value("Start Frequency")
      collection[:max_freq]=ConfigParam.get_value("Stop Frequency")
    end
    #Assuming over_time is true
    collection[:min_ts]=time_list.min
    collection[:max_ts]=time_list.max
    return collection
  end
  def Datalog::compress_overtime(collection, sample_count)
    #If the destination array is bigger than the original data then return original data.
    if (sample_count > collection[:avg].length)
      return collection
    end
    #Get the data
    min_list=collection[:min]
    max_list=collection[:max]
    avg_list=collection[:avg]
    time_list=collection[:time]
    #Calculate average interval between data points
    intvl=(time_list.max-time_list.min)/(sample_count-1)
    #Create new arrays with the first value
    new_min=[min_list[0]]
    new_max=[max_list[0]]
    new_avg=[avg_list[0]]
    new_time=[time_list[0]]
    curr_time=time_list[0]
    idx=1 #Index into original data set.
    new_idx=1 #Index into new data set.
    curr_time=time_list[idx]
    while (!curr_time.nil? && curr_time <= time_list.max)#Loop through data until we get through all data.
      next_time=[new_time[0]+ intvl*new_idx,time_list.max].min
      intvl_count=0
      if (!curr_time.nil? && curr_time <= next_time)#Loop though interval.
        while(!curr_time.nil? && curr_time <= next_time)#Loop though interval.
          intvl_count+=1
          if new_min[new_idx].nil?
            new_min[new_idx]=min_list[idx]
            new_max[new_idx]=max_list[idx]
            new_avg[new_idx]=avg_list[idx]
          else
            new_min[new_idx]=[new_min[new_idx],min_list[idx]].min
            new_max[new_idx]=[new_max[new_idx],max_list[idx]].max
            new_avg[new_idx]+=avg_list[idx]
          end
          idx+=1
          if (time_list.length > idx)
            curr_time=time_list[idx]
          else
            curr_time=nil
          end
        end
        new_time[new_idx]=next_time
        new_avg[new_idx]=new_avg[new_idx]/intvl_count
        new_idx+=1
      else
        new_min[new_idx]=min_list[new_idx-1]
        new_max[new_idx]=max_list[new_idx-1]
        new_avg[new_idx]=new_avg[new_idx-1]
        new_time[new_idx]=next_time
        new_idx+=1
      end
    end
    collection[:min]=new_min
    collection[:max]=new_max
    collection[:avg]=new_avg
    collection[:time]=new_time
    return collection
  end
  def Datalog.summarize(days) #Summarize by day all datalogs after 'days'
    ts=Date.today
    target_ts=ts-days
    sec_divisor=86400 # of seconds in a day.
    start_freq=Datalog.minimum(:start_freq) || 0
    stop_freq=Datalog.maximum(:stop_freq) || 100000000
    sql_query="select  site_id,DATE(ts) as ts, sum(sample_count) as sample_count,
      max(ts) as max_ts, avg(attenuation) as attenuation,
      min(start_freq) as start_freq, max(stop_freq) as stop_freq,
      min(min_val) as min_val, max(max_val) as max_val, avg(val)as val,
      floor(unix_timestamp(Date(ts))/?) as group_ts,
      avgarray(image,500,start_freq,stop_freq,500,#{start_freq},#{stop_freq}) as trace,
      maxarray(max_image,500,start_freq,stop_freq,500,#{start_freq},#{stop_freq}) as max_trace,
      minarray(min_image,500,start_freq,stop_freq,500,#{start_freq},#{stop_freq}) as min_trace 
        from  datalogs
        where ts < ?
        group by group_ts, site_id";
    targets=Datalog.find_by_sql( [sql_query,sec_divisor, target_ts.strftime('%F %T') ])
    #puts target_ts.strftime('%F %T')
    total_deleted=0
    total_created=0
    targets.each { |tgt|
      #puts tgt.inspect()
      transaction do
        ts=tgt.ts
        max_ts=tgt.max_ts
        potential_deleted=Datalog.count_by_sql([ "select count(*) from datalogs where "+
          "site_id=? and ts between ? and ?", tgt.site_id, ts,max_ts])
        if potential_deleted >1
          Datalog.destroy_all([ " site_id=? and ts between ? and ?", tgt.site_id, ts,max_ts])
          attr=tgt.attributes
          attr.delete("group_ts")
          attr.delete("max_ts")
          attr.delete("max_trace")
          attr.delete("min_trace")
          attr.delete("trace")
          dl=Datalog.create(attr)
          dl.max_image=tgt.max_trace.unpack('e*')
          dl.min_image=tgt.min_trace.unpack('e*')
          dl.image=tgt.trace.unpack('e*')
          dl.save
          created=Datalog.count_by_sql([ "select count(*) from datalogs where "+
            "site_id=? and ts between ? and ?",
            tgt.site_id, ts,max_ts])
          total_created+=created
        end
      end
    }
  end
  def Datalog.cal_noise_floor(dlog,an_id)
	an=Analyzer.find(an_id)
	interval=(an.stop_freq-an.start_freq)/dlog.length
	start_i = (an.nf_start_freq-an.start_freq)/interval
	stop_i = (an.nf_stop_freq-an.start_freq)/interval
	i=0
	high=an.nf_high
	low=an.nf_low
	flag=Array.new
	dlog.each {|val|
		if i>start_i && i<stop_i
			if val > high || val < low#we consider this
				flag[i]=true if flag[i].nil?
			else#within 2 mhz should also carrier
				s=(-2*10e5/interval).to_i
				e=(2*10e5/interval).to_i
				s.upto(e) do |j|
#				    puts "#{i} and #{j}" 
#					puts "#{s} and #{e}"
					flag[i+j]=false if i+j >0 && i+j < dlog.length
				end
			end
		end
		i=i+1
	}
	i=0
	sum=0
	count=0
	dlog.each {|val|
		if flag[i]==true
			sum+=val
			count=count+1
		end
		i=i+1
	}
	unless count==0
		return sum/count
	else
		return -999999999#show an error about noise floor
	end
#    count	
  end
end
