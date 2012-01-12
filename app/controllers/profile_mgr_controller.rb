class ProfileMgrController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
#    breakpoint
    @record_pages, @profiles = paginate :profiles, 
       :per_page => 10, :conditions => "status is NULL"
    @analyzers = Analyzer.find(:all).collect{ |analyzer| [analyzer.name, analyzer.id]}.sort{|a,b| a<=>b}
  end

  def new
    @profile = Profile.new
  end
  def generate_entry
    @analyzer = Analyzer.find(params[:id])
    if !@analyzer.status.nil? && @analyzer.status.eql?(12)
      flash[:warning] = 'Analyzer is in connected status.  Changes not allowed.'
    end
  end
  def generate
    sp_list=[]
    logger.debug(params.inspect())
    if !params.key?(:switch_port)
        flash[:error]= "Switch Ports required" 
        redirect_to :action => 'generate_entry'
        return
    end
    params[:switch_port].each { |sp_id,val|
      if val == '1'
        switch_port=SwitchPort.find(sp_id.to_i)
        if (switch_port.nil?)
          flash[:error]= "Switch port whth id #{sp_id} is not recognized" 
          redirect_to :action => 'generate_entry'
          return
        end
        if switch_port.purpose != SwitchPort::RETURN_PATH
          flash[:error]= "#{sp_id} is not an Ingress Monitoring port" 
          redirect_to :action => 'generate_entry'
          return
        end
        sp_list.push(sp_id)
      end
    }
    if !params.has_key?("hours")
        flash[:error]= "Hours field required." 
        redirect_to :action => 'generate_entry'
        return
    end
    if !params.has_key?("major_offset")
        flash[:error]= "Major offset is required." 
        redirect_to :action => 'generate_entry'
        return
    end
    if !params.has_key?("minor_offset")
        flash[:error]= "Minor offset is required." 
        redirect_to :action => 'generate_entry'
        return
    end
    sp_list.each { |sp_id|
      switch_port=SwitchPort.find(sp_id)
      if (switch_port.nil?)
        flash[:error]= "Switch port whth id #{sp_id} is not recognized" 
        redirect_to :action => 'generate_entry'
        return
      end
      site=switch_port.site
      if (site.nil?)
        flash[:error]= "Switch port Does not have a site." 
        redirect_to :action => 'generate_entry'
        return
      end
      hours=params["hours"].to_i
      stop_ts=site.datalogs.maximum('ts')
      if stop_ts.nil?
        flash[:notice] << "Switch port #{switch_port.name} on #{switch_port.switch.switch_name} does not have data.<BR>" 
      else
	      start_ts=stop_ts-(3600*hours)
	      result=Datalog.summarize_datalogs({:site_id => site.id, :start_ts=>start_ts, :stop_ts=>stop_ts,
	          :start_freq=>ConfigParam.get_value(ConfigParam::StartFreq),:stop_freq=>ConfigParam.get_value(ConfigParam::StopFreq)}, false)
	      max=result[:max]
	      link_loss_offset=result[:min].sum()/result[:min].length
	      prof=Profile.new()
	      prof.trace=max
	      prof.name="P" + switch_port.get_calculated_port.to_s + "_" + site.id.to_s
	      str_time1="%Y/%m/%d %H:%M:%S"
	      str_time2="%H:%M:%S"
	      prof.comment="#{site.name}@#{start_ts.strftime(str_time1)}"
	      prof.major_offset=params["major_offset"].to_i
	      prof.minor_offset=params["minor_offset"].to_i
	      prof.loss_offset=link_loss_offset
	      prof.link_loss=params["link_loss"]
	      prof.save()
	      logger.debug("PROFILE ID #{prof.id}")
	      switch_port.profile_id=prof.id
	      switch_port.save
      end
    }
    redirect_to :action => 'list'
  end

  def create
 #   breakpoint
    
    @profile = Profile.new(params[:profile])
    if @profile.save
      flash[:notice] = 'Profile was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def update
    @profile = Profile.find(params[:id])
	unit_diff=ConfigParam.find(67).val.to_i==1 ? -60 : 0
	
    if @profile.update_attributes(params[:profile])
      @profile.update_attributes(:loss_offset=>"#{params[:profile][:loss_offset].to_i+unit_diff}")	
      flash[:notice] = 'Profile was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @idd=params[:id]
    if SwitchPort.exists?(:profile_id=> @idd) || Analyzer.exists?(:profile_id=> @idd)  
	  flash[:error]='Delete Failed. This profile is still in use.'
    else
      Profile.find(params[:id]).destroy
      flash[:notice]="This profile has been Deleted."  
    end
    redirect_to :action => 'list'
  end
end
