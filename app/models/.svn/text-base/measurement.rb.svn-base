class Measurement < ActiveRecord::Base
  belongs_to :site
  belongs_to :channel
  belongs_to :measure

  def get_measurement(site_id, measure, channel, start_dt, stop_dt)
    condition_str="switch_port_id=? and dt <= ? and dt >= ? and " +
      "channel_id=? and measure_id=?, site_id, measure, channel, " +
      "stop_dt, start_dt" 
    rows=find(:all,:conditions=>[condition_str])
    min_val=nil	
    max_val=nil	
    avg_val=nil	
    count=0
    total_val=0
    rows.each { |r| 
      min_val=r.value if min_val.nil?
      max_val=r.value if max_val.nil?
      total_val+=r.value
      count++
      min_val= r.value if r.value < min_val
      max_val= r.value if r.value > max_val
    }
    avg_val = total_val/count
  end

  def Measurement.summarize(days) #Summarize by day all measurements after 'days'
    dt=Date.today
    target_dt=dt-days
    sec_divisor=86400 # of seconds in a day.
    sql_query="select channel_id, measure_id, site_id,DATE(dt) as dt,
      max(dt) as max_dt,
      floor(unix_timestamp(Date(dt))/?) as group_dt,max(iteration) as iteration,
      Round(avg(value), dec_places) as value,min(min_limit) as min_limit, 
      max(max_limit) as max_limit,SUM(IFNULL(sum_count,1)) as sum_count,
      Round(max(IFNULL(max_value,value)),dec_places) as max_value , 
      Round(min(IFNULL(min_value,value)),dec_places) as min_value 
        from measurements left join measures on measure_id=measures.id 
        where dt < ?
        group by group_dt, channel_id, measure_id,site_id";
    targets=Measurement.find_by_sql( [sql_query,sec_divisor, target_dt.strftime('%F %T') ])
    #puts target_dt.strftime('%F %T')
    total_deleted=0
    total_created=0
    targets.each { |tgt|
      transaction do
        dt=tgt.dt
        max_dt=tgt.max_dt
        potential_deleted=Measurement.count_by_sql([ "select count(*) from measurements where "+
          "channel_id=? and measure_id=? and site_id=? and dt between ? and ?",
          tgt.channel_id,tgt.measure_id, tgt.site_id, 
          dt,max_dt])
        if potential_deleted >1
          Measurement.destroy_all([
            "channel_id=? and measure_id=? and site_id=? and dt between ? and ?",
            tgt.channel_id,tgt.measure_id, tgt.site_id, 
            dt,max_dt])
          attr=tgt.attributes
          attr.delete("group_dt")
          attr.delete("max_dt")
          Measurement.create(attr)
          created=Measurement.count_by_sql([ "select count(*) from measurements where "+
            "channel_id=? and measure_id=? and site_id=? and dt between ? and ?",
            tgt.channel_id,tgt.measure_id, tgt.site_id, 
            dt,max_dt])
          total_created+=created
        end
      end
    }
  end
  def Measurement.get_recent(site_id,measure_list, channel_list)
    sql_query="select max(measurements.id) as id " +
      "from measures left join measurements on (measures.id=measurements.measure_id) " +
      "where measurements.site_id=#{site_id} and channel_id in (#{channel_list.join(',')}) and measurements.measure_id in (#{measure_list.join(',')}) " +
      "group by measurements.channel_id,measurements.measure_id order by measurements.channel_id, measurements.measure_id"
    logger.debug sql_query
    data_list=Measurement.find_by_sql(sql_query)
    measurement_list=[]
    data_list.each { |data|
      meas=Measurement.find(data.id)
      measurement_list.push(meas)
    }
    return measurement_list
  end
end
