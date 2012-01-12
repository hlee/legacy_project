require 'sf_parser.rb'
require 'ping'
require 'instr_utils.rb'
class SetupController < ApplicationController
  in_place_edit_for :sf_system_file, :display_name
  in_place_edit_for :sf_test_plan, :display_name
  def site_form
    @site=nil
    if (params.key?(:id)) && !params[:id].nil?
      id=params[:id]
      @site=Site.find(id)
    end
    if @site.nil?
      @site=Site.new()
    end
  end

  def site_save
    site_id=params[:id]
    site_name=params[:site][:name]
    sf_test_plan_id=params[:sf_test_plan_id]
    if (site_id.nil?)
      @site=Site.new()
    else
      @site=Site.find(site_id)
    end
    @site[:name]=site_name
    @site[:sf_test_plan_id]=sf_test_plan_id
    if @site.save()
      redirect_to :action => 'site_list'
    else
    render :action => 'site_form'
    end
  end
  def isolated_site
    @iso_list=Site.isolated_list
	if @iso_list.empty?
	  @iso_list=nil
	end
  end
  def delete_isolated
    Site.isolated_list.each{|site|Site.destroy(site.id)}
	flash[:notice]="All isolated site has been deleted successfully."
	redirect_to :action => 'isolated_site'
  end
  def site_delete
    id=params[:id]
    site=Site.find(id)
    @name=site.name
    anal=Analyzer.find_by_sql(["select * from analyzers where site_id = ?",id])
    port=SwitchPort.find_by_sql(["select * from switch_ports where site_id = ?",id])
    if anal.length==0 and port.length==0
      Site.destroy(id)
      flash[:notice]="Site #{@name} has been deleted."
    else
      flash[:error]="Delete Failed. Site #{@name} is still using. "
    end
    redirect_to :action => 'site_list'
  end

  def site_list
    @site_list=Site.find(:all)
  end

  def system_file_list
    @sf_system_file_list=SfSystemFile.find(:all, :conditions=>'status="A"')
  end
  def test_measure_update
    @sf_system_test = SfSystemTest.find(params[:id],
      :conditions => {
      :sf_test_plan_id => params['test_id']
      }
    )
      if @sf_system_test.update_attributes(params[:system_test])
         flash[:notice] = " #{@sf_system_test.measure[0].measure_label} updated"
         redirect_to :action=>'test_measure_list', :id => params['test_id']
      else
         render :action=> 'test_measure_list'
#	flash[:notice]="input error"
	#still have problem, can not show the error description from model
#         redirect_to :action=>'test_measure_list', :id => params['test_id'] 
      end
  end
  def test_measure_list
    @measures = Measure.find(:all)
    @test_plan = SfTestPlan.find(params[:id])
    @system_tests = SfSystemTest.find(:all, 
      :conditions => {
        :sf_test_plan_id => params[:id], 
        :test_type => @measures.collect(&:sf_meas_ident)
      }
    )
    if !params[:measure_id].nil?
      @sf_system_test = SfSystemTest.find(params[:measure_id],
        :conditions => {
        :sf_test_plan_id => params[:id]
        }
      )
      if @sf_system_test.update_attributes(params[:system_test])
         flash[:notice] = " #{@sf_system_test.measure[0].measure_label} updated"
         redirect_to :action=>'test_measure_list', :id => params[:id]
      else
         render :action=> 'test_measure_list'
      end
    end 
  end
  def test_plan_delete
    test_plan = SfTestPlan.find(params[:id])
    test_plan.destroy
    flash[:notice] = "#{test_plan['name']} deleted"
    redirect_to :action=>'test_plan_list', :id => test_plan['sf_system_file_id']
  end
  def test_plan_edit
    @test_plan = SfTestPlan.find(params[:id])
  end
  def test_channel_list
    @test_plan = SfTestPlan.find(params[:id])
    @channels = SfTestChannel.find(:all, 
      :conditions=>["sf_test_plan_id=?", 
      @test_plan.id],
      :include => :sf_channel
    )
  end
  def test_channel_update
    @test_plan = SfTestPlan.find(params[:id])
    @channels = SfTestChannel.find(:all, 
      :conditions=>["sf_test_plan_id=?", 
      @test_plan.id],
      :include => :sf_channel
    )
    flash[:notice] = "No updates submitted"
    @channels.each {|channel|
      if params[:channel][channel.id.to_s]
        params[:channel][channel.id.to_s] = params[:channel][channel.id.to_s].eql?("1") ? true : false
        unless channel.enable_flag.eql?(params[:channel][channel.id.to_s])
          channel.enable_flag = params[:channel][channel.id.to_s]
          channel.save
          flash[:notice] = "Test Channels updated for #{@test_plan.name} Test Plan"
        end
      end
    }
    redirect_to :action=>'test_channel_list', :id => params[:id]
  end
  def set_sf_test_plan_name
    @test_plan = SfTestPlan.find(params[:id])
    respond_to do |format|
      format.html {
        if @test_plan.update_attribute(:name, params[:test_plan][:name])
          flash[:notice] = "#{@test_plan['name']} was successfully updated."
          redirect_to :action => 'test_plan_list', :id => @test_plan["sf_system_file_id"]
        else
          render :action => 'test_plan_edit'
        end
      }
      format.js {
        @test_plan.update_attribute(:name, params[:value])
        render :text=>@test_plan['name']
      }
    end
  end

  def test_plan_list
    @sf_system_file=SfSystemFile.find(params[:id])
    @sf_test_plans=SfTestPlan.find(:all, :conditions=> ["sf_system_file_id=?", params[:id]])
  end

  def system_file_download
    sf_system_file=SfSystemFile.find(params[:id])
    if sf_system_file.location.nil? || sf_system_file.location.empty?
      redirect_to :action=>'system_file_list'
    else
      if File.exist?(sf_system_file.location)
            @fname = sf_system_file.location.slice(/\/[^\/]+$/) + '.bin'
        send_file(sf_system_file.location,
          :filename     => @fname.slice(1,@fname.length+3),
          :streaming    =>  true,
          :buffer_size  =>  4096)
      end
    end
    #redirect_to :action=>'system_file_list'
  end

  def system_file_delete() 
    id=params[:id]
    sf_system_file=SfSystemFile.destroy(id)
    #sf_system_file.status='D'
    redirect_to :action=>'system_file_list'
  end

  def upload_system_file
    display_name=params[:display_name]
	unless SfSystemFile.find_by_display_name(display_name).nil?
	  flash[:error] = "Display Name \"#{display_name}\" can not be duplicated."
      redirect_to :action=>'system_file_list'
      return false
	end
    if display_name.eql?('')
      flash[:error] = "Display Name can not be empty"
      redirect_to :action=>'system_file_list'
      return false
    end
    if params["system_file"].eql?('')
      flash[:error] = "Please provide a filename to upload"
      redirect_to :action=>'system_file_list'
      return false
    end
    location = "#{RAILS_ROOT}/tmp/#{display_name}"
    if params.key?("system_file")
      File.open(location,"w") {|f| 
        f.write(params["system_file"].read)
      }
      id,@current_state = SF_Parser::SFParser.system_file_load(location, display_name)
      #send_data(id, :disposition => 'inline', :type => 'text/html')
      sf = SfSystemFile.find(id)
      sf.location = location
      sf.save
    end
    redirect_to :action => 'system_file_list'
  end

  def upload_firmware
  end
  def start_firmware_upload
    if (params[:firmware]["file"].eql?(''))
      flash[:error] = "Please provide a filename to upload"
    else
      firmware_result=Firmware.save(params[:firmware])
      if (!firmware_result)
        flash[:error] = "Firmware file not recognized."
      end
    end
    redirect_to :action => "upload_firmware"
  end
  def firmware_delete() 
    filename=params[:fname]
    logger.debug("Deleting #{filename}")
    fw=Firmware.find(filename)
    if (!fw.nil?)
      fw[0].destroy()
    end
    redirect_to :action => "upload_firmware"
  end
  def maintain_db()
  end
  def datadel()
    tablename=params[:name]
      if tablename=='datalogs'
        Datalog.delete_all()
      elsif tablename=='measurements'
        Measurement.delete_all()
      elsif tablename=='down_alarms'
        DownAlarm.delete_all()
      elsif tablename=='up_alarms'
        Alarm.delete_all()
      end
    flash[:notice] = "#{tablename} has been deleted."
    redirect_to :action => "maintain_db"  
  end
#here is for the Region function
  def region_form
    @region=nil
    if (params.key?(:id)) && !params[:id].nil?
      id=params[:id]
      @region=Region.find(id)
    end
    if @region.nil?
      @region=Region.new()
    end
  end
  def region_save
    @region_id=params[:id]
    @region_name=params[:region][:name]
    @region_ip=params[:region][:ip]
    if (@region_id.nil?)
      @region=Region.new()
    else
      @region=Region.find(@region_id)
    end
#    @region[:name]=@region_name
#    @region[:ip]=@region_ip
#	  if @region.save()
    #@region = Region.find_by_id(params[:id])
    if @region.update_attributes(params[:region])
	  redirect_to :action => "region_list"
    else
      flash[:notice]="error"
      render :action=> "region_form" 
    end		
  end
  def region_delete
    id=params[:id]
    region=Region.find(id)
    name=region.name
    ana=Analyzer.find_by_sql(["select * from analyzers where region_id = ?",id])
    if ana.length!=0
      flash[:error]="Delete Failed. This region #{name} is still using."
    else
      Region.delete(id)
      flash[:notice]="region #{name} has been deleted."
    end
    redirect_to :action => "region_list"
  end

  def region_list
    @region_list=Region.find(:all)
  end
  def validate_sys
    @analyzer_list=Analyzer.find(:all)
	#@analyzer_connect=Analyzer.find_by_status(11)
	#@list=Analyzer.find_by_status(11).collect {|p| [ p.name, p.id ] }
  end
  def test_ping
    @ping_ana_id=[]
    @avg=[]
    @min_time=[]
    @max_time=[]
    @flag_time=[]
    @count = 5
    @count = params[:ping][:count] unless params[:ping][:count].size==0
    params[:analyzer].each{|id,value|
    if value.eql?("1")
      @ping_ana_id << id
      @ana=Analyzer.find(id)
      if system("ping #{@ana[:ip]} -c 2")
        @sum=`ping #{@ana[:ip]} -c #{@count}`
        @temp=@sum.slice(/(\.|\d|\/)+\//).split('/')
        @min_time << @temp[0]
        @avg << @temp[1]
        @max_time << @temp[2]
        @flag_time << true
      else 
	  @min_time << 999
      @avg << 999
      @max_time << 999
      @flag_time << false
      end 
    end  
    }
  end

  def _get_port(id)
    anl=Analyzer.find(id)
    if !anl.cmd_port.nil?
      return anl.cmd_port
    end
  end

  def switch_show
    @anl=Analyzer.find(params[:analyzer][:id])
	if @anl.status==10
		#render :text=> "analyzer #{@anl.name} is not connected.<br> Please connect it first before test switch."
	else
		retry_count=0
		begin
		  sleep 3
		  port=_get_port(@anl.id)
		  url="http://localhost:#{port}/#{params[:test][:delay]}/TSWITCH"
		  response=Net::HTTP.get(URI(url))
		rescue
		  if (retry_count < 3)
			retry_count+=1
			retry
		  else
		  end
		end    
      #render :partial=> 'switch_show', :locals => {:id => @anl.id}
	end
  end

  def show_switch_port
    ana=Analyzer.find(params[:id])
	nbr= ana[:current_nbr].nil? ? -999 : ana[:current_nbr]
	render :partial=> 'switch_status', :locals => {:port_id =>nbr,:error_msg=>ana.exception_msg}  
  end
  
  def test_snmp
	25.upto(34) do |i| 
		m = ConfigParam.find_by_ident(i)
		ip = m[:val]
		if (!ip.nil? && ip =~/^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/)
		Avantron::InstrumentUtils.snmp_alarm(ip, 1, "INGRESS", "UNKNOWN", Time.new.to_s)
		end
	end
  end
 
  def edit_plan
    
  end
end
