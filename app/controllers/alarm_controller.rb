class AlarmController < ApplicationController
  require 'time'
  in_place_edit_for :alarm, :acknowledged
  in_place_edit_for :alarm, :downacknowledged
  def down_alarm_list
    if ! has_performance?
      if has_ingress?
        redirect_to :action => 'index'
      else
        redirect_to :controller => 'main', :action => 'down_alarm_list'
      end
    end
    @criteria=[]
    @start_date=DateTime.parse((Time.now-2.years).to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
    @stop_date=DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
    sort = case params['sort']
      when "site"                 then "sites.name"
      when "al"                   then "alarm_type"
      when "ad"                   then "event_time"
      when "ed"                   then "end_time"
      when "channel"              then "channels.channel_name"
      when "measure"              then "measures.measure_label"
      when "as"                   then "acknowledged"
      when "site_reverse"         then "sites.name DESC"
      when "al_reverse"           then "alarm_type DESC"
      when "ad_reverse"           then "event_time DESC"
      when "ed_reverse"           then "end_time DESC"
      when "channel_reverse"      then "channels.channel_name DESC"
      when "measure_reverse"      then "measures.measure_label DESC"
      when "as_reverse"           then "acknowledged DESC"
      else "active desc"
    end
    @criteria.push("name LIKE ?", "%#{params[:query]}%") unless params[:query].nil?
    if params.key?('id')
      @criteria.push("id=#{params['id']}")
    elsif params.keys.length == 0
      @criteria=[]
    else
      if params.key?('alarm_type') && !params['alarm_type'].nil? && params['alarm_type'].length > 0
        @criteria.push("alarm_type='#{params['alarm_type']}'")
        @type = params['alarm_type'].to_i
      else
        @type = ''
      end
      if params.key?('acknowledged') && !params['acknowledged'].nil? && params['acknowledged'].length > 0
        if (params['acknowledged'].to_i == 1)
          @criteria.push("acknowledged='1'")
        else
          @criteria.push("(acknowledged='0' or acknowledged is null)")
        end
      end
      if params.key?('active') && !params['active'].nil? && params['active'].length > 0
        if (params['active'].to_i == 1)
          @criteria.push("active='1'")
        else
          @criteria.push("(active='0' or active is null)")
        end
      end
      if params.key?('start_date') &&params['start_date'].length > 0
        @start_date=DateTime.parse(params['start_date']).strftime('%Y-%m-%d %H:%M:%S').to_s
        @criteria.push("event_time >= '#{@start_date}'") 
      end
      if params.key?('stop_date') && params['stop_date'].length > 0
        @stop_date=DateTime.parse(params['stop_date']).strftime('%Y-%m-%d %H:%M:%S').to_s
        @criteria.push("event_time <= '#{@stop_date}'") 
      end
      if params.key?('site_id') && params['site_id'].length > 0
        @site_id=params['site_id']
        @criteria.push("down_alarms.site_id = '#{@site_id}'") 
      else 
        @site_id=''
      end
      if !params['channel'].nil? && params['channel'].length > 0
        @channel=params['channel']
        @criteria.push("channel_id = '#{@channel}'") 
      else 
        @channel=''
      end
      if params.key?('measure_id') && !params['measure_id'].nil? && params['measure_id'].length > 0
        @measure=params['measure_id']
        @criteria.push("measure_id='#{params['measure_id']}'")
      else 
        @measure=''
      end
    end
	sort = sort+",active desc"
    if @criteria.length <= 0
      #@record_pages, @alarms = paginate :down_alarms, :order => sort, :per_page => 20, :include => ['channel', 'site', 'measure']
      @alarms = DownAlarm.paginate :page => params[:page], 
        :include => ['site', 'channel', 'measure'],
		:per_page => 16,
        :order => sort
      @total = DownAlarm.count
    else
      #@record_pages, @alarms = paginate :down_alarms, :order => sort, :per_page => 20, :conditions=> @criteria.join(' and '), :include => ['channel', 'site', 'measure']
      @alarms = DownAlarm.paginate :page => params[:page], 
        :order => sort,
		:per_page => 16,
        :include => ['site', 'channel', 'measure'],
        :conditions => @criteria.join(' and ')
      @total = DownAlarm.count(:conditions => @criteria.join(' and '))
    end
    @filter=params['filter']
    @sort = sort
    if request.xml_http_request?
      render :partial => "down_alarm_table", :layout => false
    end
  end
  def index
    if ! has_ingress?
      if has_performance?
        redirect_to :action => 'down_alarm_list'
      else
        redirect_to :controller => 'main', :action => 'index'
      end
    end
    @criteria=[]
    @start_date=DateTime.parse((Time.now-2.years).to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
    @stop_date=DateTime.parse(Time.now.to_s).strftime('%Y-%m-%d %H:%M:%S').to_s
    sort = case params['sort']
      when "site"           then "sites.name"
	  when "al"             then "alarm_type,alarm_level desc"
	  when "al_reverse"     then "alarm_type desc,alarm_level desc"   
      when "ad"             then "event_time"
      when "ed"             then "end_time"
      when "as"             then "acknowledged"
      when "site_reverse"   then "sites.name DESC"
      when "ad_reverse"     then "active desc,event_time DESC"
      when "ed_reverse"     then "active desc,end_time DESC"
      when "as_reverse"     then "acknowledged DESC"
      else "active desc,event_time desc, event_time_hundreths desc"
    end
    @criteria.push("name LIKE ?", "%#{params[:query]}%") unless params[:query].nil?
    if params.key?('id')
      @criteria.push("id=#{params['id']}")
    elsif params.keys.length == 0
      @criteria=[]
    else
      if params.key?('acknowledged') && !params['acknowledged'].nil? && params['acknowledged'].length > 0
        if (params['acknowledged'].to_i == 1)
          @acknowledged = 1
          @criteria.push("acknowledged='1'")
        else
          @criteria.push("(acknowledged='0' or acknowledged is null)")
          @acknowledged = 0
        end
      end
      if params.key?('active') && !params['active'].nil? && params['active'].length > 0
        if (params['active'].to_i == 1)
          @criteria.push("active='1'")
          @active = 1
        else
          @criteria.push("(active='0' or active is null)")
          @active = 0
        end
      end
	  if params.key?('alarm_level') && !params['alarm_level'].nil? && params['alarm_level'].length > 0
	    @criteria.push("alarm_type='#{params['alarm_level']}'")
        @alarm_level = params['alarm_level'].to_i
      else
        @alarm_level = ''
	  end
      if params.key?('start_date') &&params['start_date'].length > 0
        @start_date=DateTime.parse(params['start_date']).strftime('%Y-%m-%d %H:%M:%S').to_s
        @criteria.push("event_time >= '#{@start_date}'") 
      end
      if params.key?('stop_date') && params['stop_date'].length > 0
        @stop_date=DateTime.parse(params['stop_date']).strftime('%Y-%m-%d %H:%M:%S').to_s
        @criteria.push("event_time <= '#{@stop_date}'") 
      end
      if !params['site_id'].nil?  && params['site_id'].length > 0
        site_id=params['site_id']
        @criteria.push("site_id = '#{site_id}'") 
      end
    end
	sort = sort+",active desc"
    if @criteria.length <= 0
      #@record_pages, @alarms = paginate :alarms, :order => sort, :per_page => 20
      @alarms = Alarm.paginate :page => params[:page], :order => sort,:joins =>"left join sites on sites.id=site_id",:per_page => 16
      @total = Alarm.count
    else
      #raise @criteria.join(' and ')
      #@record_pages, @alarms = paginate :alarms, :order => sort, :per_page => 20, :conditions=> @criteria.join(' and ')
      @alarms = Alarm.paginate :page => params[:page], 
        :order => sort,
        :per_page => 16, 		
	    :joins =>"left join sites on sites.id=site_id",
        :conditions=> @criteria.join(' and ')
      @total = Alarm.count(:conditions => @criteria.join(' and '))
    end
    @filter=params['filter']
    @sort = sort
    if request.xml_http_request?
      render :partial => "table", :layout => false
    end
  end

  def set_alarms_acknowledged
    @i = Alarm.find(params[:id])
    if params[:value].to_i == 1
      @i.update_attribute(:acknowledged,1)
      render :text=>"Ack", :layout => false
    else 
      @i.update_attribute(:acknowledged,0)
      render :text=>"UnAck", :layout => false
    end
  end
  def set_alarms_downacknowledged
    @i = DownAlarm.find(params[:id])
    if params[:value].to_i == 1
      @i.update_attribute(:acknowledged,1)
      render :text=>"Ack", :layout => false
    else 
      @i.update_attribute(:acknowledged,0)
      render :text=>"UnAck", :layout => false
    end
  end
end
