require 'instr_utils'

class NetworkController < ApplicationController
  in_place_edit_for :switch_port, :name
  in_place_edit_for :switch_port, :profile
  in_place_edit_for :site, :name
  in_place_edit_for :schedule, :switch_port
  attr_accessor :analyzer_id 

  def index
    @analyzer_list=Analyzer.find(:all)
    if (flash[:warning].nil?)
      flash[:warning] = ""
    end
    if (flash[:error].nil?)
      flash[:error] = ""
    end
    if (flash[:notice].nil?)
      flash[:notice]=""
    end
    start = ConfigParam.get_value("Monitor Start Port")
    stop = ConfigParam.get_value("Monitor Stop Port")
    count = Analyzer.count
    if stop - start <= count
      unless flash[:warning] =~ /You have too many Analyzers/
        flash[:warning]+=" You have too many Analyzers (#{stop - start} available monitoring ports, #{count} analyzers)<BR>"
      end
    end
    @analyzer_id=nil;
    session[:analyzer_id]=@analyzer_id
  end

  def update_analyzer
    analyzer=Analyzer.find(params[:id])
    render :partial => 'analyzer_status_show', :locals => { :analyzer => analyzer }
  end
  
  def update_analyzer_list
    @analyzer_list=Analyzer.find(:all)
    if (flash[:warning].nil?)
      flash[:warning] = ""
    end
    if (flash[:error].nil?)
      flash[:error] = ""
    end
    if (flash[:notice].nil?)
      flash[:notice]=""
    end
 @time = Time.now
    render :partial => 'analyzer_list' 
  end

  def update_schedule_dtls
    flash[:error] = "" if flash[:error].nil?
    sched=Schedule.find(params[:schedule][:id])
    if sched.nil?
      sched.new()
    end
    sched.attributes=params[:schedule]
    sched.save
    unless sched.errors.empty?
      sched.errors.each { |attr,msg| flash[:error] += "\n#{msg}" }
    end
    redirect_to :action => 'schedule_edit',:id =>sched.analyzer.id
  end
  def set_switch_port_profile
    @switch_port = SwitchPort.find(params[:id])
    if params[:value].eql?("0")
      @switch_port.update_attribute(:profile_id, nil)
    else
      @profile = Profile.find(params[:value])
      @switch_port.update_attribute(:profile_id, @profile.id)
    end
    name = @switch_port.profile.nil? ? "Use Analyzer Setting" : @switch_port.profile.name
    render :text=>name
  end
  def set_switch_port_purpose
    @switch_port = SwitchPort.find(params[:id])
    @switch_port.update_attribute(:purpose, params[:value].to_i)
    #@switch_port = SwitchPort.find(params[:id])
    render :text=>@switch_port.purpose_label
  end
  def set_scheduled_sources_switch_port_id
    @i=ScheduledSource.find(params[:id])
    #f=Switch_Port_Id.find(params[:value])
    @i.update_attribute(:switch_port_id,params[:value])
    #Lookup switch port ID
    @analyzer_id=nil;
    switch=SwitchPort.find(params[:value])
    render :text=>switch.name
  end

  def set_scheduled_sources_stat_trace_flag
    @i=ScheduledSource.find(params[:id])
    #f=Switch_Port_Id.find(params[:value])
    @i.update_attribute(:switch_port_id,params[:value])
    #Lookup switch port ID
    render :text=>params[:value] ? "Stat Trace On":"Stat Trace Off"
  end

  def init_schedule()
    
    logger.debug("In Init Schedule net controller")
    order_nbr=0
    @ports=[]
    @analyzer=Analyzer.find(params[:id])
    @analyzer_id=@analyzer.id;
    port_count=@analyzer[:port_count]
    schedule_id=nil
    @schedule=@analyzer.schedule
    if (!@schedule.nil?)
      logger.debug "a"
      schedule_id=Schedule.find(:first,:conditions=>"analyzer_id=#{params[:id]}").id
      ScheduledSource.destroy_all("schedule_id=#{schedule_id}")
    else
      logger.debug "b"
      @schedule=Schedule.new(:analyzer_id=>@analyzer.id)
      @schedule.acquisition_count = 1;
      @schedule.trace_polling_period = 15;
      @schedule.save() or raise "ERROR:  Unable to save @schedule (ERROR: #{@schedule.errors.full_messages})"
      schedule_id = @schedule.id
      ScheduledSource.destroy_all("schedule_id=#{schedule_id}")
    end
    @schedule.init_schedule_dtls()
    @analyzer=Analyzer.find(@analyzer.id)
    @scheduled_sources=@analyzer.schedule.scheduled_sources;
    redirect_to :action => 'schedule_edit', :id=>params[:id]
  end

  def delete_from_sched
    analyzer_id = nil
    params["scheduled_sources"].each_key {|scheduled_source|
      if analyzer_id.nil?
        analyzer_id = ScheduledSource.find(scheduled_source).schedule.analyzer.id
      end
      if params["scheduled_sources"][scheduled_source].eql?("1")
        ScheduledSource.delete(scheduled_source)
      end
    }
    redirect_to :action => 'schedule_edit',:id =>analyzer_id
  end

  def add_to_schedule
    sp=ScheduledSource.new(params["post"])
    sp.save()
    redirect_to :action => 'schedule_edit',:id =>sp.schedule.analyzer
  end

  def switch_list
    @analyzer=Analyzer.find(params[:id])
    @switch_list=@analyzer.switches
    @analyzer_id=analyzer_id;
    if !@analyzer.status.nil? && @analyzer.status > 10
      flash[:warning] = 'Analyzer is in connected status.  Switch changes not allowed.'
    end
  end

  def set_schedule_switch_port
    @scheduled_source = ScheduledSource.find(params[:id])
    @scheduled_source.update_attribute(:switch_port_id, params[:value])
    render :text=>"#{@scheduled_source.switch_port.switch.switch_name}/#{@scheduled_source.switch_port.name}"
  end
  def reset_profile
    id=params[:id]
	if SwitchPort.update_all("profile_id = NULL",["switch_id = ?",id])
    	flash[:notice]="Reset Alarm Profile Successfull."
	else
	    flash[:error]="Error occur"
	end
	redirect_to :action => 'switch_edit',:id=>id
  end
  def scheduled_source_edit
    @scheduled_source = ScheduledSource.find(params[:id])
    @ports=[]
    if @scheduled_source.switch_port.nil?
      @scheduled_source.destroy
      redirect_to :action => 'index'
      return
    end
    @analyzer = @scheduled_source.switch_port.switch.analyzer
    @order_nbr = @analyzer.schedule.scheduled_sources.index(@scheduled_source)
    @order_nbr += 1
    switch_list=@analyzer.switches
    switch_list.each {|switch|
      SwitchPort.find(:all,:conditions=>"switch_id=#{switch.id}",:order=>"name").each { |switch_port|
        @ports.push(["#{switch.switch_name}/#{switch_port.name}", switch_port.id])
      }
    }
  end
  def scheduled_source_update
    @scheduled_source = ScheduledSource.find(params[:id])
    @scheduled_source.update_attribute(:switch_port_id, params[:value])
    redirect_to :action => 'schedule_edit', :id => @scheduled_source.switch_port.switch.analyzer.id
  end
  def schedule_edit
    @analyzer=Analyzer.find(params[:id])
    if !@analyzer.status.nil? && @analyzer.status > 11
      flash[:warning] = 'Analyzer is in connected status.  Changes not allowed.'
    end
    port_count=@analyzer[:port_count]
    switch_list=@analyzer.switches
    @ports=[]
    switch_list.each {|switch|
      SwitchPort.find(:all,:conditions=>"switch_id=#{switch.id}",:order=>"name").each { |switch_port|
        @ports.push(["#{switch.switch_name}/#{switch_port.name}", switch_port.id])
      }
    }
    #@schedule=@analyzer.schedule;
    #if @schedule.nil?
    #   @schedule=Schedule.new(:analyzer_id=>@analyzer.id)
    #   @schedule.save()
    #end
    #@analyzer_id=@analyzer.id;
    @schedule = Schedule.find(:first,:conditions=>"analyzer_id=#{@analyzer.id}")
    if @schedule.nil?
      redirect_to :action => 'init_schedule', :id => @analyzer.id
      return
    end
    @scheduled_sources=@analyzer.schedule.scheduled_sources;
  end

  def schedule_port
    if ((!params[:id].nil?) && (params[:id] !=''))
      port_id=params[:id].split("_")[1]
      if session[:schedule].nil?
        session[:schedule]=[port_id]
      else
        session[:schedule].push(port_id)
      end
    end
    @analyzer_id=nil;
    render :partial => 'schedule'
  end

  def switch_new
    @analyzer=Analyzer.find(params[:id])
    if !@analyzer.status.nil? && !@analyzer.status.eql?(10)
      redirect_to :action => 'switch_list', :id => @analyzer.id
    end
    @switch = Switch.new
    @switch[:analyzer_id]=params[:id]
    @port_list=[]
    if @analyzer.switches.count == 0
      @port_list=[['First',1],['Master',0]]
    else
      16.times { |idx| 
        # FIXME For now we assume 16 ports.  Later we will look at the number of ports on the master switch.
        port=idx+1
        @port_list.push(['Port ' << port.to_s,port])
      }
    end
    @analyzer_id=params[:id];
  end

  def switch_create
    @switch = Switch.new(params[:switch])
    analyzer=Analyzer.find(params[:switch]['analyzer_id'])
    site_prefix="?/"
    if (@switch.master_switch_flag)
       @switch[:port_count] = 0
    end
    if !analyzer.nil?
      site_prefix=analyzer.name+"/"
    end
    if @switch.save
      flash[:notice] = 'Switch was successfully created.'
      #currently we are skipping this.
      #Now we create the initial ports
      port_count=@switch[:port_count]
      port_count.times { |prt_idx|
        prt_nbr=prt_idx+1
        @switch_port=@switch.switch_ports.find(:first,:conditions=>["port_nbr=?",prt_nbr])
        if (@switch_port.nil?)
          node_label=sprintf "Node_%03d",prt_nbr
          @switch_port=@switch.switch_ports.new(:name=>node_label,:switch_id=>@switch[:id],:port_nbr=>prt_nbr,:purpose=>SwitchPort::RETURN_PATH)
          @switch_port.save()
	  port_num=sprintf "%03d", @switch_port.get_calculated_port()
          site_name=site_prefix+"/" + port_num.to_s
      logger.debug("Generateing #{site_name}");
          site_id=Site.create_if_needed(site_name)
          @switch_port.site_id=site_id
          @switch_port.save()
        end
      }
      redirect_to :action => 'switch_list', :id=>params[:switch]['analyzer_id']
    else
      flash[:error] = "Unable to save switch (ERROR: #{@switch.errors.full_messages})"
      redirect_to :action => 'switch_new', :id=>params[:switch]['analyzer_id']
    end
  end

  def switch_edit
    @switch = Switch.find(params[:id])
    @profile_list=
       Profile.find_active_profiles.collect{ |s| [s.name,s.id]}.sort {|a,b| a<=>b}
    @profile_list.unshift(['Use Analyzer Setting', '0'])
    @port_purpose = [
      ['Maintenance', '0'], 
      ['Return Path', SwitchPort::RETURN_PATH], 
      ['Forward Path', SwitchPort::FORWARD_PATH]
    ]
    @test_plans = Array.new
    @analyzer = @switch.analyzer
    if !@analyzer.status.nil? && @analyzer.status > 10
      flash[:warning] = 'Analyzer is in connected status.  Switch changes not allowed.'
    end
    @analyzer_id=@switch.analyzer.id
    session[:switch_id]=@switch.id
  end

  def switch_update
    @switch = Switch.find(params[:id])
    analyzer=@switch.analyzer
	@analyzer=analyzer
	@profile_list=
       Profile.find_active_profiles.collect{ |s| [s.name,s.id]}.sort {|a,b| a<=>b}
    @profile_list.unshift(['Use Analyzer Setting', '0'])
    @port_purpose = [
      ['Maintenance', '0'], 
      ['Return Path', SwitchPort::RETURN_PATH], 
      ['Forward Path', SwitchPort::FORWARD_PATH]
    ]
    site_prefix=""
    if !analyzer.nil?
      site_prefix=analyzer.name+"/"
    end
    if (params["switch"]["master_switch_flag"])
       @switch[:port_count] =0
       @switch.switch_ports.each {|sp| sp.destroy()}
    end
    if @switch.update_attributes(params[:switch])
      flash[:notice] = 'Switch was successfully updated.'
      redirect_to :action => 'switch_list', :id=>@switch.analyzer_id
    else
      render :action => 'switch_edit'
    end
    #@analyzer_id=@switch.analyzer.id;
  end

  def switch_delete
    sw=Switch.find(params[:id])
    Switch.find(params[:id]).destroy
    redirect_to :action => 'switch_list', :id => sw.analyzer_id
  end
  #Analyzer Functions
  def analyzer_create
    if params[:analyzer][:site_id].to_i == 0
    #else
    #  raise params[:analyzer].inspect()
    end
    
    @analyzer = Analyzer.new(params[:analyzer])
	@site= Site.new(params[:site])
    @analyzer.status = 10
    if @analyzer.save
      if params[:site][:name]!=''
          begin	  
		  @analyzer.site.update_attribute(:name, params[:site][:name])
		  rescue=> ex
		  flash[:error]="#{ex.message}"
		  render :action => 'analyzer_new'
		  end
		  #@site.update_attribute()
		  flash[:notice] = 'Analyzer was successfully created.'
		  redirect_to :action => 'index'
	  else
		  flash[:notice] = 'Analyzer was successfully created.'
		  redirect_to :action => 'index'
      end	  
    else
      #raise @analyzer.errors().full_messages().join()
      flash[:error] = 'Analyzer was not created.'
      render :action => 'analyzer_new'
    end
    @analyzer_id=@analyzer.id;
  end

  def analyzer_edit
    @analyzer = Analyzer.find(params[:id])
    @site=@analyzer.site
    @analyzer_id=@analyzer.id;
    if !@analyzer.status.nil? && @analyzer.status > 11
      flash[:warning] = 'Analyzer is in connected status.  Changes not allowed.'
    else
      flash[:warning] = ''
    end
  end
  def analyzer_new
    @analyzer = Analyzer.new
    @analyzer_id=nil;
  end
  def debug
  end
  def analyzer_update
    @analyzer = Analyzer.find(params[:id])
	@site=@analyzer.site
    if @analyzer.site_id.to_i == 0
      logger.debug("handling site");
      site_id = Site.create_if_needed(params[:site][:name])
      params[:analyzer][:site_id]=site_id
    end
	#make sure when user stop auto_connect. we can handle
    if @analyzer.auto_mode !=3 and @analyzer.att_count < 9
	  @analyzer.update_attribute(:att_count,-1)
	end
    if @analyzer.update_attributes(params[:analyzer])
      @analyzer.site.update_attribute(:name, params[:site][:name])
      flash[:notice] = 'Analyzer was successfully updated.'
      if @analyzer.switch_type == 0
        redirect_to :action => 'analyzer_edit', :id => @analyzer.id
      else
        redirect_to :action => 'switch_list', :id => @analyzer.id
      end
    else
      flash[:notice] = 'Analyzer failed to update.'
      @analyzer_id=@analyzer.id;
      render :action => 'analyzer_edit', :id => @analyzer.id
    end
  end
  def analyzer_delete
    @an=Analyzer.find(params[:id])
	ingress=@an.has_ingress_data
	downstream=@an.has_downstream_data
	if ingress || downstream 
		render :partial => 'analyzer_delete_form',:object=> @an,:locals => {:ingress=> ingress,:downstream=> downstream},:layout=> 'network'
	else
		@an.destroy
		redirect_to :action => 'index'
	end
  end

  def associate_delete #here I also deleted the alarm if they have. and we can separate it from data while delete analyzer.
	an=Analyzer.find(params[:id].to_i)
	dt=""
	if params[:data][:ingress]=="yes"
		dt="ingress data"
		an.drop_ingress_data 
	end
	if params[:data][:downstream]=="yes"
	    dt=dt+" downstream data"
		an.drop_downstream_data
	end
    ingress=an.has_ingress_data
	downstream=an.has_downstream_data
	if ingress || downstream#here is will not triggle the before destroy, then all the site will not delete
	  Analyzer.delete(an.id)
	  Switch.destroy_all(["analyzer_id is ?",an,id])
	else# here means all data has been deleted, so we can just destroy analyzer. then all accossidated site will be delete.
	  an.destroy
	end
	if dt==""
	  flash[:notice]="Only Analyzer '#{an.name}' has been deleted."
	else
	  flash[:notice]="Analyzer '#{an.name}' with it's #{dt} have been deleted."
	end
	redirect_to :action => 'index'	
  end
  def port_edit
    @port=SwitchPort.find(params[:id])
    @site=@port.site
    sw=@port.switch
    session[:switch_id]=@port.switch.id
    @analyzer_id=sw.analyzer.id
    @analyzer=sw.analyzer
    if !@analyzer.status.nil? && @analyzer.status > 10
      flash[:warning] = 'Analyzer is in connected status.  Changes not allowed.'
    end
    session[:port_id]=@port.id
    @profile_list=Profile.find_active_profiles
    @test_plans = Array.new
    @port_purpose = [
      ['Maintenance', '0'], 
      ['Return Path', SwitchPort::RETURN_PATH], 
      ['Forward Path', SwitchPort::FORWARD_PATH]
    ]
  end
  def port_update
    port=SwitchPort.find(params[:id])
    port.name=params['port']['name']
    port.profile_id=params['port']['profile_id']
    port.site.update_attribute(:name,params['site']['name'])
    if params['port']['purpose'].eql?("0")
      port.purpose=nil
    else
      port.purpose=params['port']['purpose']
    end
    #send_data("-#{params['port']['name']}-", :disposition => 'inline', :type => 'text/html', :filename => "measurement.png")
    if port.save
      flash[:notice] = "Port #{port.name} was successfully updated."
      redirect_to :action => 'analyzer_edit', :id => Switch.find(port.switch_id).analyzer_id
    else
      @analyzer = port.switch.analyzer
      flash[:error] = "Error updating #{port.name} port."
      redirect_to :action => 'port_edit', :id => params[:id]
    end
  end


  #######################################################################
  #Monitoring Functions
  def maintenance
    anl=Analyzer.find(params[:id])
	if anl.att_count < 9
	  anl.update_attributes({:auto_mode=> 3})
	  SystemLog.log("Auto connect Mode shut down.","This is probably because that user stop Ingress or performance",SystemLog::RECONNECT,anl.id)
    end	
    _send_command('MAINT')
  end
  def start_ingress
    analyzer_id=params[:id]
    analyzer=Analyzer.find(analyzer_id)
	if analyzer.status== Analyzer::SWITCHING
		flash[:error] = "Unable to start Ingress Monitoring.Analyzer #{analyzer.name} is running switch test."
        redirect_to :action => 'index'
        return
	end
	g_start_freq=ConfigParam.find(23)
    g_stop_freq=ConfigParam.find(24)
    unless SwitchPort.count(:all, 
      :conditions => ["switch_id in (?) and purpose = ?", 
        analyzer.switches.collect {|sw| sw.id}, SwitchPort::RETURN_PATH]) > 0
      flash[:error] = 'Unable to start Ingress Monitoring. You have no Return Path Switch Ports.'
      redirect_to :action => 'index'
      return
    end
	if analyzer[:start_freq].to_i<(g_start_freq[:val].to_i*10e5) || analyzer[:stop_freq].to_i>(g_stop_freq[:val].to_i*10e5)
	  flash[:error] = 'Unable to start Ingress Monitoring. start freq or stop freq is out of global range. check log for detail.'
      redirect_to :action => 'index'
	  return
 	end
	
    sched=analyzer.schedule
    if sched.nil?
      flash[:error] = 'Unable to start Ingress Monitoring. Schedule invalid.'
      redirect_to :action => 'index'
      return
    end
    sched.errors.clear()
    if !sched.verify_scheduled_ports
      flash[:error] = 'Unable to start Ingress Monitoring. ' + sched.errors.full_messages()[0]
      redirect_to :action => 'index'
    else
	analyzer.update_attributes({:att_count=> -1})
      _send_command('INGRESS')
    end
  end
  def start_performance
    anl=Analyzer.find(params[:id])
	if anl.status== Analyzer::SWITCHING
		flash[:error] = "Unable to start Performance Monitoring. Analyzer #{analyzer.name} is running switch test."
        redirect_to :action => 'index'
        return
	end
    if (anl.site.nil?)
      flash[:notice] = 'Unable to start Performance Monitoring.  No system file assigned.'
      redirect_to :action => 'index'
    else
      analyzer_id=params[:id]
      analyzer=Analyzer.find(analyzer_id)
      if analyzer.switches.count==0
	  anl.update_attributes({:att_count=> -1})
        _send_command('DOWNSTREAM')
        return
      end
      unless SwitchPort.count(:all, 
        :conditions => ["switch_id in (?) and purpose = ?", 
          analyzer.switches.collect {|sw| sw.id}, SwitchPort::FORWARD_PATH]) > 0
        flash[:error] = 'Unable to start Performance Monitoring. You have no Forward Path Switch Ports.'
        redirect_to :action => 'index'
        return
      end
      sched=analyzer.schedule
      if analyzer.switches.nil? || sched.nil?
        flash[:error] = "Unable to start Performance Monitoring on #{analyzer.name}. Schedule invalid."
        redirect_to :action => 'index'
        return false
      end
      sched.errors.clear()
      if !sched.verify_scheduled_ports
        flash[:error] = "Unable to start Performwance Monitoring on #{analyzer.name}." + sched.errors.full_messages()[0]
        redirect_to :action => 'index'
        return false
      else
	  anl.update_attributes({:att_count=> -1})
        _send_command('DOWNSTREAM')
      end
    end
  end
  def reason_entry
    @anl=Analyzer.find(params[:id])
	#redirect_to :action=>'stop_monitor',:id=>params[:id]
  end
  def process_reason
    id = params[:reason][:id]
	reason=params[:reason][:content].blank? ? "No reason input." : params[:reason][:content]
	an = Analyzer.find(id)
	if an.status == 12
	  SystemLog.log("User \"#{current_user.email}\" has stopped Ingress because: #{reason}","Here is some reason to stop monitor.",SystemLog::MESSAGE,id)
	elsif an.status == 13
	  SystemLog.log("User \"#{current_user.email}\" has stopped Performance because: #{reason}","Here is some reason to stop monitor.",SystemLog::MESSAGE,id)
	end
	redirect_to :action=>'stop_monitor',:id=>id,:flag=>'dis'
  end
  def stop_monitor
    anl=Analyzer.find(params[:id])
	if anl.att_count < 9 and params[:flag] == 'dis'
	  anl.update_attributes({:auto_mode=> 3})
	  SystemLog.log("Auto connect Mode shut down.","User Disconnect",SystemLog::RECONNECT,anl.id)
    end
	  _send_command('NOMON')
  end
  def reset_monitor
    anl=Analyzer.find(params[:id])
    master_port=ConfigParam.get_value("Monitor Start Port").to_i
    request=Net::HTTP.new('localhost',master_port)
    response=request.get("/RESET?#{anl.id}")
    data=response.body.split(',')
    redirect_to :action => 'index'
  end
  def _get_port
    anl=Analyzer.find(params[:id])
    if !anl.cmd_port.nil?
      return anl.cmd_port
    end
    master_port=ConfigParam.get_value("Monitor Start Port").to_i
    request=Net::HTTP.new('localhost',master_port)
    begin
      response=request.get("/GETPORT?#{anl.id}")
    rescue Errno::ECONNREFUSED
      flash[:error] = 'Unable to contact Performance Monitoring Daemon.  Consult your User Guide to restart it.'
      return nil
    end
    data=response.body.split(',')
    if data.nil? || data[2] != 'PORT'
      flash[:error] = 'Unable to contact Performance Monitoring Daemon.  Consult your User Guide to restart it.'
      return nil
    else
      port=data[3].to_i
      return port
    end
  end
  def _send_command(cmd)
    anl=Analyzer.find(params[:id])
    anl.processing = Time.now
    anl.save
    anl.clear_exceptions()
    anl.clear_progress()
    logger.debug("In Send Command for #{cmd}")
    port=_get_port()
    if port.nil?
      redirect_to :action => 'index'
      return
    end
    logger.debug("Got response from master")
    #anl.status=Analyzer::PROCESSING
    anl.save()
    logger.debug("Set analyzer to processing")
    retry_count=0
    begin
      sleep 3
      url="http://localhost:#{port}/#{cmd}"
      response=Net::HTTP.get(URI(url))
    rescue 
      if (retry_count < 9)
        retry_count+=1
        retry
      else
        logger.debug("lvks response is #{response}")
        #$logger.debug("lvkss response is #{response}")
        SystemLog.log("+++- response is #{response},nil,SystemLog::MESSAGE,analyzer_id")
        anl.status=Analyzer::DISCONNECTED
        anl.save()
      end
    end
    SystemLog.log("+++-+ response is #{response},nil,SystemLog::MESSAGE,analyzer_id") 
    redirect_to :action => 'index'
  end
  def _old_send_command(cmd)
    logger.debug("In Send Command for #{cmd}")
    anl=Analyzer.find(params[:id])
    master_port=ConfigParam.get_value("Monitor Start Port").to_i
    request=Net::HTTP.new('localhost',master_port)
    begin
      response=request.get("/GETPORT?#{anl.id}")
    rescue Errno::ECONNREFUSED
      flash[:error] = 'Unable to contact Performance Monitoring Daemon.  Consult your User Guide to restart it.'
      redirect_to :action => 'index'
      return
    end
    data=response.body.split(',')
    port=0
    logger.debug("Got response from master")
    if data.nil? || data[2] != 'PORT'
      raise "Server Not Running #{data.inspect()}"
    else
      port=data[3].to_i
    end
    anl.status=Analyzer::PROCESSING
    anl.save()
    logger.debug("Set analyzer to processing")
    retry_count=0
    begin
      #sleep 3
      request=Net::HTTP.new('localhost',port)
      response=request.get("/#{cmd}")
    rescue 
      if (retry_count < 3)
        retry_count+=1
        retry
      else
        anl.status=Analyzer::DISCONNECTED
        anl.save()
      end
    end
    redirect_to :action => 'index'
  end
  def syslog_list()
    @analyzer=''
    cond_str=''
    cond_params=[]
    if (params.key?(:id) && params.key?(:msg_type))
      @msg_type=params[:msg_type].to_i
      @analyzer=Analyzer.find(params[:id])
      analyzer_id=@analyzer.id
      msg_type=params[:msg_type]
      @analyzer=Analyzer.find(analyzer_id)
      cond_str="analyzer_id=? and level >= ?"
      cond_params=["analyzer_id=? and level >= ?",analyzer_id, msg_type.to_i]
      #@sys_log_list=SystemLog.find(:all,:conditions=>["analyzer_id = ? and level>=?",analyzer_id, msg_type.to_i],:order => 'id desc')
    elsif (params.key?(:id))
      @analyzer=Analyzer.find(params[:id])
      analyzer_id=@analyzer.id
      cond_params=["analyzer_id = ?",analyzer_id]
      #@sys_log_list=SystemLog.find(:all,:conditions=>["analyzer_id = ?",analyzer_id],:order => 'id desc')
    else
      @analyzer=""
      cond_params=nil
      #@sys_log_list=SystemLog.find(:all,:order => 'ts desc')
    end
    if cond_params.nil?
      @record_pages, @sys_log_list = paginate :system_logs, :order => 'ts desc', :per_page => 20
    else
      @record_pages, @sys_log_list = paginate :system_logs, :order => 'ts desc', :per_page => 20, :conditions=> cond_params
    end
    render :layout=>"blank"
  end
  def upgrade_firmware()
    id=params["id"]
    @id=id
  end
  def start_firmware_upgrade()
    if !params.key?(:id)
      flash[:error] = 'No analyzer selected.'
      redirect_to :action => 'upgrade_firmware'
      return
    end
    if !params.key?(:firmware_ref)
      flash[:error] = 'No Firmware selected.'
      redirect_to :action => 'upgrade_firmware'
      return
    end
    analyzer_id=params[:id]
    firmware_ref=params[:firmware_ref]
    fw=Firmware.find(firmware_ref)
    analyzer=Analyzer.find(analyzer_id)
    if fw.nil? || fw.length != 1
      flash[:error] = 'Firmware not found.'
      redirect_to :action => 'upgrade_firmware'
      return
    end
    if analyzer.nil? 
      flash[:error] = 'Analyzer not found.'
      redirect_to :action => 'upgrade_firmware'
      return
    end
    analyzer.firmware_ref=firmware_ref
    analyzer.save
    _send_command('FIRMWARE')
    #     redirect_to :action => 'index'
  end
  def reset_analyzer()
    anl=Analyzer.find(params[:id])
    anl.cmd_port=nil
    anl.clear_exceptions()
    anl.clear_progress()
    anl.status=Analyzer::DISCONNECTED
    anl.save
    flash[:notice]='Please wait 30 seconds before connecting the analyzer so it can finish rebooting.'
    begin
      Avantron::InstrumentUtils.reset(anl.ip)
    rescue Errno::EHOSTUNREACH
      flash[:notice]='Unable to reboot analyzer. Analyzer must be on network and Mips Based (have USB Port)'
    rescue Timeout::Error
      flash[:notice]='Unable to reboot analyzer. Analyzer must be on network and Mips Based (have USB Port)'
    end
    if !anl.pid.nil? && (anl.pid.to_i > 0)
      begin
        Process.kill("SIGKILL",anl.pid)
      rescue Errno::ESRCH,Errno::EPERM
      end
      #anl.status=Analyzer::PROCESSING
      anl.pid=nil
      anl.save
    end
    redirect_to :action => 'index'
  end

  def datalog_profile_destroy()
    dlp=DatalogProfile.find(params[:id])
    analyzer_id=dlp.analyzer_id
    dlp.destroy
    redirect_to :action => 'datalog_profile_list', :id => analyzer_id
  end
  def datalog_profile_list()
    @anl=Analyzer.find(params[:id])
    @analyzer_id=params[:id]
    @dp_list=@anl.datalog_profiles
  end
  def datalog_profile_form
    @datalog_profile=nil
    if (params.key?(:id)) && !params[:id].nil?
      id=params[:id]
      @datalog_profile=DatalogProfile.find(id)
    end
    if @datalog_profile.nil?
      @datalog_profile=DatalogProfile.new()
      @datalog_profile.analyzer_id=params["analyzer_id"]
    end
  end
  def datalog_profile_save()
    datalog_profile_id=params['datalog_profile']["id"] || nil
    if datalog_profile_id.nil? || datalog_profile_id == ''
      @datalog_profile=DatalogProfile.new(params['datalog_profile'])
      if @datalog_profile.save()
        redirect_to :action => 'datalog_profile_list', :id => @datalog_profile.analyzer_id
      else
        render :action => 'datalog_profile_form'
      end
    else
      @datalog_profile=DatalogProfile.find(datalog_profile_id)
      if (@datalog_profile.update_attributes( params['datalog_profile']))
        redirect_to :action => 'datalog_profile_list', :id => @datalog_profile.analyzer_id
      else
        render :action => 'datalog_profile_form'
      end
    end
  end
end
