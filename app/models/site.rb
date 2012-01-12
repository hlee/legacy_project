class Site < ActiveRecord::Base
  
  #has_many :upstreams_as_child, :foreign_key=> 'child_id', :class_name => 'Upstream'
  #has_many :upstreams_as_parent, :foreign_key=> 'parent_id', :class_name => 'Upstream'
  #has_many :children, :through => :upstreams_as_child
  has_many :datalogs
  has_many :alarms
  has_many :down_alarm
  has_many :measurements
  has_many :snapshots
  validates_uniqueness_of :name
  validates_presence_of   :name
  validates_format_of     :name,
                          :with => /\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i	
  validates_length_of :name, :within => 1..30,
                             :too_short=>"please enter at least %d character",
                       	     :too_long =>"please enter at most %d character"

  def Site.create_if_needed(site_name)
    # ===Site.create_if_needed(site_name)
    # <b>Class Function</b>
    # Creates a site if no site exist with site_name. It then returns the new site's id.
    # If site name exist then it just returns the name of the existing id.
    rec=find(:first,{:conditions=>["name=?",site_name]})
    logger.debug "CREATE IF NEEDED #{site_name}"
    if (rec.nil?)
      logger.debug "CREATING #{site_name}"
      rec=create({:name=>site_name})
    end
    return rec.id
  end

  def Site.alarm_sites(category=nil)
    # ===Site.alarm_sites(category)
    # <b>Class Function</b>
    # Returns an array of (id,site_name) that have data in the given category.
    # The three legal possible categories are :downstream, :upstream & :nil
    # If nil it returns all sites that have data both :upstream and :downstream
    data=[]
    if category != :downstream
      sql_query="select sites.id as id, sites.name as name,count(*) as cnt from alarms left join sites on sites.id=alarms.site_id group by sites.id having cnt > 0"
      results=Site.find_by_sql(sql_query).collect{|rec| [rec.name,rec.id]}
      data += results
    end
    if category != :upstream
      sql_query="select sites.id as id, sites.name as name,count(*) as cnt from down_alarms left join sites on sites.id=down_alarms.site_id group by sites.id having cnt > 0"
      results=Site.find_by_sql(sql_query).collect{|rec| [rec.name,rec.id]} 
      data += results
    end
    return data
  end

  def Site.data_sites(site_type)
    # ===Site.data_sites(category)
    # <b>Class Function</b>
    # Returns an array of (id,site_name) that have data in the given category.
    # The three legal possible categories are :downstream, :upstream & :nil
    # If nil it returns all sites that have data both :upstream and :downstream
    list=[]
	if site_type == 3
		sql_query='SELECT st.name,st.id,sp.purpose,sp.id as sp_id,sp.name as sp_name,sp.port_nbr,an.id as a_id,an.name as a_name FROM switches sw inner join analyzers an on sw.analyzer_id=an.id inner join switch_ports sp on sw.id = sp.switch_id inner join sites st on sp.site_id = st.id where an.status =12'
		list=Site.find_by_sql(sql_query).collect{|rec| 
		  site_obj={}
				site_obj[:name]=rec.name
        site_obj[:site_id]=rec.id.to_i
		  	site_obj[:analyzer_name]=rec.a_name
		  	site_obj[:purpose]=rec.purpose.to_i
		  	site_obj[:port_name]=rec.sp_name
        site_obj[:port_nbr]=rec.port_nbr.to_i	  
        site_obj[:analyzer_id]=rec.a_id.to_i
		  	site_obj[:port_id]=SwitchPort.get_calculated_port(rec.sp_id.to_i).to_i	
		  site_obj
		}
	else
		if site_type == 1
		  sql_query='select st.id,st.name,an.name as an_name,an.id as an_id,sp.id as sp_id,sp.name as sp_name,sp.port_nbr as sp_nbr from sites st left join switch_ports sp on st.id = sp.site_id left join switches sw on sp.switch_id = sw.id left join analyzers an on (st.id=an.site_id or sw.analyzer_id = an.id) where st.id in (select distinct site_id from measurements)'
		end
		if site_type == 2
		  sql_query='select st.id,st.name,an.name as an_name,an.id as an_id,sp.id as sp_id,sp.name as sp_name,sp.port_nbr as sp_nbr from sites st left join switch_ports sp on st.id = sp.site_id left join switches sw on sp.switch_id = sw.id left join analyzers an on sw.analyzer_id=an.id where st.id in (select distinct site_id from datalogs)'
		end
		list=Site.find_by_sql(sql_query).collect{|rec| 
		site_obj={}
	    site_obj[:name]=rec.name
        site_obj[:site_id]=rec.id.to_i
		site_obj[:analyzer_name]=rec.an_name.nil? ? 'NO ANALYZER' : rec.an_name
		site_obj[:port_name]=rec.sp_name.nil? ? 'NO SWITCH PORT' : rec.sp_name
        site_obj[:port_nbr]=rec.sp_nbr.nil?	? -1 : rec.sp_nbr.to_i			  
        site_obj[:analyzer_id]=rec.an_id.nil? ? -1 : rec.an_id.to_i
        site_obj[:port_id]=(rec.sp_id.nil? or rec.an_id.nil?) ? -1 : SwitchPort.get_calculated_port(rec.sp_id.to_i).to_i
		site_obj
		} 
	end
    list
  end

  def get_profile
    # ===get_profile
    # <b>Instance Function</b>
    # Returns the profile that fits this site.
    anl=nil
    swp=SwitchPort.find(:first,:conditions=> {:site_id=> id.to_i})
    if !swp.nil?
      if !swp.profile.nil?
    logger.debug "returning swp.profile"
        return swp.profile
      end
      swt=swp.switch
      if swt.nil?
        #This should never happen, but in case it does lets try the analyzer.
        anl=nil 
      end 
      anl=swt.analyzer
    end
    if anl.nil?
      anl=Analyzer.find(:first,:conditions=>{:site_id=>id.to_i})
    end
    if anl.nil?
    logger.debug "returning nil for no profile"
      return nil #Cannot find analyzer or switch port associated with site.
    end
    logger.debug "Returning analyzer's profile"
    return anl.profile
  end
  def analyzer
    # ===analyzer
    # <b>Instance Function</b>
    # Returns the analyzer that fits this site.
    anl=Analyzer.find(:first,:conditions=>{:site_id=>id.to_i})
    if anl.nil?
      swp=SwitchPort.find(:first,:conditions=> {:site_id=> id.to_i})
      if swp.nil?
        return nil
      end
      return swp.switch.analyzer
    else
      return anl
    end
  end
  def Site.isolated_list
  #find all site with out analyzer and switches_port
    Site.find_by_sql('SELECT s.id,s.name FROM sites s left outer join analyzers ana on s.id=ana.site_id left outer join switch_ports sp on s.id=sp.site_id where ana.site_id is null and sp.site_id is null')
  end
  
  def analyzer_port
    swp=SwitchPort.find(:first,:conditions=> {:site_id=> id.to_i})
    if swp.nil?
      return nil
    else
      return swp
    end
  end
  def isolated?
  #when we need to deleted isolated data with analyzer, we call this to check.
    analyzer=Analyzer.find_by_site_id(self.id)
	switch_port=SwitchPort.find_by_site_id(self.id)
	if analyzer.nil? && switch_port.nil?
	  return false
	else
	  return true
	end
  end
  def short_name
    if name.length < 13
      return name
    else 
      return "..." + name.slice(-10,10)
    end
  end
    before_destroy { |site| Datalog.destroy_all "site_id = #{site.id}"   }  
    before_destroy { |site| Measurement.destroy_all "site_id = #{site.id}" }
    before_destroy { |site| Alarm.destroy_all "site_id = #{site.id}" }
    before_destroy { |site| DownAlarm.destroy_all "site_id = #{site.id}" }  
end
