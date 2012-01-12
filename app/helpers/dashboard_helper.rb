module DashboardHelper
  def port_link(site_id, analyzer_status,img_html,purpose=nil,title=nil)
    if !purpose.nil? && purpose == SwitchPort::RETURN_PATH
      return link_to(img_html,
        {:controller =>  'alarm', 
        :action     =>  'index',
        :site_id    =>  site_id},
		:title=> title
      )
    elsif !purpose.nil? && purpose == SwitchPort::FORWARD_PATH
      return link_to(img_html,
        {:controller =>  'alarm', 
        :action     =>  'down_alarm_list',
        :site_id    =>  site_id},
		:title=> title
      )
    elsif analyzer_status==Analyzer::INGRESS
      return link_to(img_html,
        {:controller =>  'alarm', 
        :action     =>  'index',
        :site_id    =>  site_id},
		:title=> title
      )
    else 
      # If we don't have an assigned purpose for this port and
      # the analyzer is not in ingress monitoring mode then just assume
      # downstream monitoring.
      return link_to(img_html,
        {:controller =>  'alarm',
        :action     =>  'down_alarm_list',
        :site_id    =>  site_id },
		:title=> title
      )
    end
  end

  def site_active_alarm(site_id)
      if DownAlarm.find(:first,:conditions => ["site_id=? and active=1",site_id])
        return "alarm_active"
      else
        return "monitored"
      end
  end
  def port_class(switch_port)
    analyzer=switch_port.switch.analyzer
    if analyzer.status.nil? || analyzer.status < 12
      return "blank"
    end
    if analyzer.schedule.scheduled_sources.find(:all, :conditions=>"switch_port_id = #{switch_port.id}").length > 0
      if switch_port.purpose == SwitchPort::RETURN_PATH && analyzer.status == Analyzer::INGRESS
        if Alarm.find(:first, :conditions => ["site_id=? and active=1", switch_port.site_id])
          return get_grade(switch_port.id)
        else
          return get_grade(switch_port.id)
        end
      end
      if switch_port.purpose == SwitchPort::FORWARD_PATH && analyzer.status == Analyzer::DOWNSTREAM
        if DownAlarm.find(:first,:conditions => ["site_id=? and active=1",switch_port.site_id])
          return "alarm_active"
        else
          return "monitored"
        end
      end
    end
    return "blank"
  end
  def noise(port_id)
    site_id=SwitchPort.find(port_id).site_id
	unit_diff=ConfigParam.find(67).val.to_i==1 ? 60 : 0
	noise=Datalog.find_by_sql(["select avg(noise_floor) as noise_floor from datalogs where site_id = ?",site_id])[0].noise_floor
    sprintf("%0.1f",noise+unit_diff) unless noise.nil?
  end
  def show_analyzer(s_port_id)

    switch=Switch.find_by_id(SwitchPort.find_by_id(s_port_id).switch_id)
    analyzer=Analyzer.find_by_id(switch[:analyzer_id])
    return analyzer[:name]
  end
  	def sort_td_class_helper(param)
	  result = 'class="sortup"' if params[:sort] == param
	  result = 'class="sortdown"' if params[:sort] == param + "_reverse"
	  return result
	end
	def sort_link_helper(text, param)
	  key = param
	  key += "_reverse" if params[:sort] == param
	  options = {
	      :url => {:action => 'list', :params => params.merge({:sort => key, :page => nil})},
	      :update => 'table',
	      :before => "Element.show('spinner')",
	      :success => "Element.hide('spinner')"
	  }
	  html_options = {
	    :title => "Sort by this field",
	    :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => nil}))
	  }
	  link_to_remote(text, options, html_options)
	end
    def show_port(site_name)
        swp=SwitchPort.find_by_site_id(Site.find_by_name(site_name))
        if (swp.nil?)
          return 'NONE'
        else
          return swp.name
        end
    end
    def show_wd_analyzer(site_name)
        site_id=Site.find_by_name(site_name)
        s_port=SwitchPort.find_by_site_id(site_id)
        if (s_port.nil?)
          analyzer=Analyzer.find_by_site_id(site_id)
        else
          switch=Switch.find_by_id(s_port[:switch_id])
          analyzer=Analyzer.find_by_id(switch[:analyzer_id])
        end
        if (analyzer.nil?)
          return "UNKNOWN"
        else
          return analyzer[:name]
        end
    end	

    def get_grade(port_id)
      unit_diff=ConfigParam.find(67).val.to_i==1 ? 60 : 0
      noise_floor = noise(port_id).to_f - unit_diff
      ana=SwitchPort.find(port_id).switch.analyzer
      if ana.breakpoint1.nil? || ana.breakpoint2.nil? || ana.breakpoint3.nil? || ana.breakpoint4.nil?
        return "gradeA"
      end
      if noise_floor <= ana.breakpoint1
        "gradeA"
      elsif noise_floor > ana.breakpoint1 && noise_floor <= ana.breakpoint2
        "gradeB"
      elsif noise_floor > ana.breakpoint2 && noise_floor <= ana.breakpoint3
        "gradeC"
      elsif noise_floor > ana.breakpoint3 && noise_floor <= ana.breakpoint4
        "gradeD"
      elsif noise_floor > ana.breakpoint4
        "gradeE"
      else
        "gradeA"
       end

    end
end
