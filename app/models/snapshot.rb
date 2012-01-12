class Snapshot < ActiveRecord::Base
  include ImageFunctions
  belongs_to :site
  def image=(data)
    write_image(:image, data)
  end
  def image
    return read_image(:image)
  end
 
  def Snapshot.get_sessions(start_dt=nil, stop_dt=nil,source=nil, site_name=nil)
    session_list=[]
    conditions=[]
    params=[]
 
    if !start_dt.nil? && start_dt.length > 2
      conditions.push("create_dt>'#{start_dt}'")
    end
    if !stop_dt.nil? && stop_dt.length > 2
      conditions.push("create_dt<'#{stop_dt}'")
    end
    if !source.nil? && source.length > 2 && source != "all"
      conditions.push("source='#{source}'")
    end
    
    if !site_name.nil? && site_name.length > 2 
      site_name='%' + site_name + '%';
      site_list=Site.find(:all, :conditions =>["name like (?)", site_name])
      site_ids = site_list.collect { |st|  st.id}
      site_cond="site_id in ("+ site_ids.join(",") + ")"
      conditions.push(site_cond)
    end
    session_groups=Snapshot.find(:all, :group=>:session, :order => "create_dt desc" , :conditions=>conditions.join(" and "))
    session_groups.each { |session_rec|
       condition_str=conditions.join(" and ")
       session_str=session_rec.session
       if condition_str.length > 1
         condition_str="session='#{session_str}' and #{condition_str}"
       else
         condition_str="session='#{session_str}'"
       end
       puts condition_str
       start_date=Snapshot.minimum(:create_dt, :conditions=>condition_str)
       stop_date=Snapshot.maximum(:create_dt, :conditions=>condition_str)
       snapshots=Snapshot.count({:group=>:site_id, :conditions=>condition_str})
       
       total=0
       snapshots.each{|snap| total += snap[1]}
       if (snapshots.length > 1)
        session_list.push({:session=>session_str, :site_id=>nil, :source=>session_rec.source, :snap_count =>total, :start_dt=>start_date, :stop_dt=>stop_date})
       else
        session_list.push({:session=>session_str, :site_id=>session_rec.site_id, :source=>session_rec.source, :snap_count =>total, :start_dt=>start_date, :stop_dt=>stop_date})
       end
    }
    return session_list
  end
end
