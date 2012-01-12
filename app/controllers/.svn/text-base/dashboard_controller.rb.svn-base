class DashboardController < ApplicationController
  def index
    if ! has_license?
      redirect_to :controller => 'licenses', :action => 'index'
    end
    render :layout =>'igoogle'
  end
  
  def main
  	@analyzer_list=Analyzer.find(:all)
  end
  def i_4
    render :layout =>'igoogle'
  end
=begin  
  def i_3
    render :layout =>false
  end
  
  def i_4
    render :layout =>'igoogle'
  end

  def i_5
    render :layout =>false
  end
  
  def i_6
    render :layout =>'igoogle'
  end  
=end
  def widget_1
    render :partial =>'widget1',:layout=>false  
  end
  def widget_2
    @tr=(params[:time_r] ||= 8).to_i
    render :partial =>'widget2',:layout=>false,:object => @tr
  end
  def widget_3
    @tr=(params[:time_r] ||= 8).to_i
    render :partial =>'widget3',:layout=>false,:object => @tr
  end
  def widget_4
    render :partial =>'widget4',:layout=>false  
  end
  def widget_5
    render :partial =>'widget5',:layout=>false  
  end
  def edit
    render :layout =>'igoogle'
  end
  
  def save
    data=params['data']
    col=data.split('+')
    max_id=Widget.find(:first,:order=>"id desc").id
    [0,1].each{ |j|
      i=0
      unless col[j].nil?
        col[j].split('-').each{|wd|
          rs=wd.split('|')
          i+=1
          wg=Widget.new
          wg.user_id=current_user.id
          wg.wg_id=rs[1]
          wg.wg_title=Widget.find(:first,:conditions=>["user_id is NULL and wg_id=?",rs[1]]).wg_title
          wg.column_num=j+1
          wg.li_num=i
          wg.collapsed=1
          co=Widget.find(:first,:conditions=>["user_id=? and wg_id=?",current_user.id.to_i,rs[1].to_i])
          #wg.custom_setting=current_user.id.to_s+"__"+rs[1].to_s+"_"+co.nil?.to_s
          wg.collapsed= co.collapsed? ? 1 : 0 unless co.nil?
          c_setting=Widget.find(:first,:conditions=>["user_id=? and wg_id=?",current_user.id,rs[1]])
          wg.custom_setting = c_setting.custom_setting unless c_setting.nil?	
          wg.wg_style=rs[0]
          wg.save
        }
      end
    }
    Widget.destroy_all(["user_id=? and id<=?",current_user.id,max_id])
	unless params['h_data'].nil?
		head=params['h_data'] 
		wg=Widget.find(:first,:conditions=>["wg_id=0 and user_id=?",current_user.id],:order=>"li_num asc")
        wg=Widget.new if wg.nil?
		wg.update_attributes(:wg_style=>head,:user_id=>current_user.id,:wg_id=>0)
	end
    render :text=>"Saved Successfully." ,:layout=>false
  end
  
  def save_main
    data=params['data']
	
    col=data.split('+')
    Widget.destroy_all(["user_id=?",current_user.id])
    [0,1].each{ |j|
      i=0
      unless col[j].nil?
        col[j].split('-').each{|wd|
          rs=wd.split('|')
          i+=1
          wg=Widget.new
          wg.user_id=current_user.id
          wg.wg_id=rs[1]
          wg.wg_title=Widget.find(:first,:conditions=>["user_id is NULL and wg_id=?",rs[1]]).wg_title
          wg.column_num=j+1
          wg.li_num=i
          wg.collapsed= rs[2]=~ /.*none.*/i ? 0 : 1
          wg.wg_style=rs[0]
          wg.custom_setting=rs[3] if rs[3]=~ /\d+/i 
          wg.save
        }
      end
    }
    
	unless params['h_data'].nil?
		head=params['h_data'] 
		wg=Widget.find(:first,:conditions=>["wg_id=0 and user_id=?",current_user.id],:order=>"li_num asc")
        wg=Widget.new if wg.nil?
		wg.update_attributes(:wg_style=>head,:user_id=>current_user.id,:wg_id=>0)
	end
    render :text=>"Saved Successfully." ,:layout=>false
  end 
   
  def save_custom_setting
    data=params['data']
    r_data=data.split('_')
    if r_data[0]=='1' || r_data[0]=='2' || r_data[0]=='3'
      wg=Widget.find(:first,:conditions=>["wg_id=? and user_id=?",r_data[0],r_data[2]])
      wg.update_attribute('custom_setting',r_data[1])
    end
    render :text=>r_data[0],:layout=>false
  end
  
  def DashboardController.show
    #return 11
    #redirect_to :action=>'index', :controller=>'alarm'
    render :layout => 'index', :controller => 'alarm'
  end
  def adjust_breakpoint
    sorted=[]
    ana = Analyzer.find(params['data'])
    ana.switches.each do|switch|
      switch.switch_ports.each do |switch_port|
        if switch_port.is_return_path?
          sorted.push(noise(switch_port.id).to_f)
        end
      end
    end
    sorted = sorted.sort
    grade_num = sorted.length/5
    bp = case sorted.length%5
               when 0 then [(sorted[grade_num-1].to_f + sorted[grade_num].to_f)/2, (sorted[2*grade_num-1].to_f + sorted[2*grade_num].to_f)/2,
                            (sorted[3*grade_num-1].to_f + sorted[3*grade_num].to_f)/2, (sorted[4*grade_num-1].to_f + sorted[4*grade_num].to_f)/2]
               when 1 then [(sorted[grade_num].to_f + sorted[grade_num+1].to_f)/2, (sorted[2*grade_num].to_f + sorted[2*grade_num+1].to_f)/2,
                            (sorted[3*grade_num].to_f + sorted[3*grade_num + 1].to_f)/2, (sorted[4*grade_num].to_f + sorted[4*grade_num + 1].to_f)/2]
               when 2 then [(sorted[grade_num].to_f + sorted[grade_num+1].to_f)/2, (sorted[2*grade_num+1].to_f + sorted[2*grade_num+2].to_f)/2,
                            (sorted[3*grade_num+1].to_f + sorted[3*grade_num+2].to_f)/2, (sorted[4*grade_num+1].to_f + sorted[4*grade_num+2].to_f)/2]
               when 3 then [(sorted[grade_num].to_f + sorted[grade_num+1].to_f)/2, (sorted[2*grade_num+1].to_f + sorted[2*grade_num+2].to_f)/2,
                            (sorted[3*grade_num+2].to_f + sorted[3*grade_num+3].to_f)/2, (sorted[4*grade_num+2].to_f + sorted[4*grade_num+3].to_f)/2]
               when 4 then [(sorted[grade_num].to_f + sorted[grade_num+1].to_f)/2, (sorted[2*grade_num+1].to_f + sorted[2*grade_num+2].to_f)/2,
                            (sorted[3*grade_num+2].to_f + sorted[3*grade_num+3].to_f)/2, (sorted[4*grade_num+3].to_f + sorted[4*grade_num+4].to_f)/2]
               end
    unit_diff=ConfigParam.find(67).val.to_i==1 ? 60 : 0
    bp[0]=bp[0] - unit_diff
    bp[1]=bp[1] - unit_diff
    bp[2]=bp[2] - unit_diff
    bp[3]=bp[3] - unit_diff
    render :text=>"#{bp[0]},#{bp[1]},#{bp[2]},#{bp[3]}",:layout=>false
    #redirect_to :controller=>'dashboard', :action=>'index'
  end
  
  def noise(port_id)
    site_id=SwitchPort.find(port_id).site_id
        unit_diff=ConfigParam.find(67).val.to_i==1 ? 60 : 0
        noise=Datalog.find_by_sql(["select avg(noise_floor) as noise_floor from datalogs where site_id = ?",site_id])[0].noise_floor
    sprintf("%0.1f",noise+unit_diff).to_f unless noise.nil?
  end
  
  def save_head
    head=params[:h_data]
	wg=Widget.find(:first,:conditions=>["wg_id=0 and user_id=?",current_user.id],:order=>"li_num asc")
    wg=Widget.new if wg.nil?
	wg.update_attributes(:wg_style=>head,:user_id=>current_user.id,:wg_id=>0)
	render :text=>"Saved Successfully." ,:layout=>false
  end

  def custom_breakpoints
    ana = Analyzer.find(params['data1'])
    unit_diff=ConfigParam.find(67).val.to_i==1 ? 60 : 0
    ana.breakpoint1=params['data2'].to_f - unit_diff
    ana.breakpoint2=params['data3'].to_f - unit_diff
    ana.breakpoint3=params['data4'].to_f - unit_diff
    ana.breakpoint4=params['data5'].to_f - unit_diff
    ana.save()
    render :text=>"Save Successfull." ,:layout=>false
    #redirect_to :controller=>'dashboard', :action=>'index'
  end

end
