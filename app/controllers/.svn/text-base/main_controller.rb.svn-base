class MainController < ApplicationController
  def index
    if ! has_ingress?
      if has_performance?
        redirect_to :action => 'down_alarm_list'
      else
        redirect_to :controller => 'config_params', :action => 'list'
      end
    end
    @sort_by = (params[:sort] ||= "")
    page=(params[:time_range] ||= 4).to_i
    st=Date.today()
    time_range=params[:time_range].to_i
    if (time_range == 1)
      @std=Date.today-1
      st=@std.to_s
    elsif (time_range == 2)
      @std=Date.today-7
      st=@std.to_s
    elsif (time_range == 3)
      @std=Date.today-30
      st=@std.to_s
    else
      @std=nil
      st=""
    end
    page=(params[:page] ||=1).to_i
    recs_per_page=20
    offset=(page-1)*recs_per_page
    sql_results=Alarm.group_by_site(st, params[:sort])
    @alarm_summary=Alarm.group_by_site(st, params[:sort])
    records={}
    record_list=[]
    @total={:acknowledged=>0,:unacknowledged=>0, :recent=>''}
    if false
    sql_results.each { |result|
      site_descr=result.site_name
      if !records.key?(site_descr)
        records[site_descr]={
          :acknowledged=>0,
          :unacknowledged=>0,
          :recent=>''
        }
      end
      key = ((result['state']==Alarm.ack_inact()) ? :acknowledged : :unacknowledged )
      @total[key]+=result['cnt'].to_i
      records[site_descr][key] = result['cnt']
      records[site_descr]["anl_site"] = site_descr
      records[site_descr]["site_id"] = result.id
      records[site_descr]["alarm_type"] = (result['typ'] == 'I') ? 'INGRESS' : 'DOWNSTREAM'
      prev_dt=records[site_descr][:recent]
      curr_dt=(result["dt"]>prev_dt) ? result["dt"] : prev_dt
      @total[:recent]=(@total[:recent]> curr_dt) ?  @total[:recent] : curr_dt
      records[site_descr][:recent]=curr_dt
    }
    records.keys.sort.each { |descr|
      record_list.push(records[descr])
    }
    @record_pages, @alarm_summary= paginate :sql_results, :per_page => 20
    end
  end
  def down_alarm_list
    @sort_by = params[:sort] || ""
    page=(params[:time_range] ||=4).to_i
    st=Date.today()
    time_range=params[:time_range].to_i
    if (time_range == 1)
      @std=Date.today-1
      st=@std.to_s
    elsif (time_range == 2)
      @std=Date.today-7
      st=@std.to_s
    elsif (time_range == 3)
      @std=Date.today-30
      st=@std.to_s
    else
      @std=nil
      st=""
    end
    page=(params[:page] ||=1).to_i
    recs_per_page=20
    offset=(page-1)*recs_per_page
    sql_results=DownAlarm.group_by_site(st, params[:sort])
    @alarm_summary=DownAlarm.group_by_site(st, params[:sort])
    records={}
    record_list=[]
    @total={:acknowledged=>0,:unacknowledged=>0, :recent=>''}
    if false
    sql_results.each { |result|
      site_descr=result.site_name 
      ident=site_descr + "," + result.meas_id.to_s+","+result.alarm_type
      if !records.key?(ident)
        records[ident]={
          :unacknowledged=>0,
          :acknowledged=>0,
          :recent=>''
        }
      end
      key = ((result['state']==DownAlarm.ack_inact()) ? :acknowledged : :unacknowledged )
        
      @total[key]+=result['cnt'].to_i
      records[ident][key] = result['cnt']
      records[ident]["anl_site"] = site_descr
      records[ident]["site_id"] = result.id
      meas = Measure.find(result.meas_id)
      records[ident]["meas"] = meas
      records[ident]["alarm_type"] = result.alarm_type
      records[ident]["alarm_type_descr"] = ((result.alarm_type.to_i == 1) ? "Major" : "Minor") 
      prev_dt=records[ident][:recent]
      curr_dt=(result["dt"]>prev_dt) ? result["dt"] : prev_dt
      @total[:recent]=(@total[:recent]> curr_dt) ?  @total[:recent] : curr_dt
      records[ident][:recent]=curr_dt
    }
    records.keys.sort.each { |descr|
      record_list.push(records[descr])
    }
    @record_pages=Paginator.new self, record_list.length, recs_per_page, params[:page]
    @record_list=record_list[offset..(offset + recs_per_page -1)]
    end
  end
end
