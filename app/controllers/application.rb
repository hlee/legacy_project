# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require_dependency 'user'
  require_dependency 'role'
  require_dependency 'static_permission'
  acts_as_current_user_container :anonymous_user => AnonymousUser
  include LicenseSystem
 
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_demo_session_id'

  before_filter :check_database_connection
  before_filter :check_permissions
  before_filter :setup_flash
=begin  
  around_filter :rescue_record_not_found

  def rescue_record_not_found
    begin
      yield
	 rescue 
#    rescue ActiveRecord::RecordNotFound
      rescue_404
    end
  end
=end

  def check_database_connection
    unless ActiveRecord::Base.connection.active?
      ActiveRecord::Base.connection.reconnect!
    end
  end

  def setup_flash
    flash[:error]   = "" if flash[:error].nil?
    flash[:warning] = "" if flash[:error].nil?
    flash[:notice]  = "" if flash[:notice].nil?
  end

  def check_permissions
    if request.env['CONTENT_TYPE'].to_s.match(/x-amf/)
      return
    end
    if params[:controller].eql?("services") 
      return
    end
    begin
      unless User.exists?(current_user)
        raise
      end
    rescue
      self.current_user = AnonymousUser.new
    end
    # Ignore requests to auth/login
    if params[:controller].eql?("auth") && params[:action].eql?("login")
      return
    end
    # Ignore requests to licenses
    if params[:controller].eql?("licenses")
      return
    end
    permission = sprintf("%s/%s", params[:controller], params[:action])
    if ENV['RAILS_ENV'] == 'test' && ENV["SKIP_AUTH"] == "yes"
      return
    end
    if ! has_license?
      redirect_to :controller => 'licenses', :action => 'index' and return
    end
    if ConfigParam.find_by_name("Allow Anonymous").val.eql?("no") && current_user.is_anonymous?
      flash[:error] = "Sorry, anonymous access is turned off.  Please log in."
      session[:return_to] = request.request_uri
      redirect_to :controller => 'auth', :action => 'login' and return
    end
    unless StaticPermission.find_by_identifier(permission).nil?
      if current_user.is_anonymous?
        flash[:error] = "Sorry, you must be logged in to access #{permission}."
        session[:return_to] = request.request_uri
        redirect_to :controller => 'auth', :action => 'login' and return
      else
        user = User.find(current_user.id)
        # Permission is required for this controller/action,
        # check to see if they have the required permission
        unless user.has_static_permission?(permission)
          flash[:error] = "Sorry, user #{current_user.email} does not have sufficient permission to access #{permission}."
          redirect_to :controller => 'main', :action => 'index' and return
        end
      end
    end
  end

  def _build_dt_aggregator(time_agg)
    if (time_agg=='DoW')
      return ' DAYOFWEEK(dt) '
    elsif (time_agg=='WEEK')
      return ' concat(year(dt),"-",week(dt)) '
    elsif (time_agg=='HoW')
      return ' DATE(dt) '
    elsif (time_agg=='DAY')
      return ' DATE(dt) '
    elsif (time_agg=='HoD')
      return ' - '
    end
  end
  def _meas_filter(filter_params)
    # Validation.  Make sure entry is leagal!
    #if (filter_params['rows'] == filter_params['columns'] )
    #   err="Row selection cannot equal Column selection"
    #   return [nil,err,nil,nil]
    #elsif !filter_params.key?('measure_id')
    if !filter_params.key?('measure_id')
      err="You must select at least one measure."
      return [nil,err,nil,nil]
    elsif ((filter_params['rows'] != 'measure_id')  &&
      (filter_params['columns'] != 'measure_id')) &&
      (filter_params.key?('measure_id')  &&
      (filter_params['measure_id'].length > 1 ))
      err="To Have multiple measures then meausre must be the row or the column selection"
      return [nil,err,nil,nil]
    end
    #Build Selection Criteria
    criteria=[]

    #Filter channels, sites, and measures based on selected items.
    ['channel_id','site_id','measure_id'].each { |field|
      if filter_params.key?(field)
        subselection=nil
        filter_params[field].each { |elem_id|
          if (subselection.nil?)
            subselection=''
          else
            subselection += ' or '
          end
          subselection = subselection + "(#{field} = #{elem_id})"
        }
        criteria.push("("+subselection+")")
      end
    }

    #Add Start Date to filter..
    if filter_params['start_year'].length > 0
      year=filter_params['start_year']
      month=filter_params['start_month']
      day=filter_params['start_day']
      criteria.push("dt >= '#{year}-#{month}-#{day}'") 
    end
    #Add Stop Date to filter..
    if filter_params['stop_year'].length > 0
      year=filter_params['stop_year']
      month=filter_params['stop_month']
      day=filter_params['stop_day']
      criteria.push("dt <= '#{year}-#{month}-#{day}'") 
    end
    group_by=[]
    primary=''
    secondary=''
    if (filter_params['rows'] == 'dt')
      primary=_build_dt_aggregator(filter_params['time_agg']) + ' as dtx_r '
    else
      primary=filter_params['rows'] 
    end
    if (filter_params['columns'] == 'dt')
      secondary=_build_dt_aggregator(filter_params['time_agg']) + 'as dtx_c '
    else
      secondary=filter_params['columns'] 
    end
    group_by.push(filter_params['columns'])
    query="select #{filter_params['columns']},#{filter_params['rows']},#{filter_params['agg_method']}(value) as value from measurements where " +
    criteria.join(' and ') + " group by 2,1 " 
    query="select #{secondary}, #{primary},#{filter_params['agg_method']}(value) as value from measurements where " +
    criteria.join(' and ') + " group by 2,1 " 
    result=Measurement.find_by_sql(query)
    row_key=filter_params['rows']
    col_key=filter_params['columns']
    row_labels=[]
    col_labels=[]
    table={}
    #TODO This code assumes that the select found data.  This is bad.
    for data in result
      if (row_key == 'dt')
        row_label=data['dtx_r']
      elsif row_key=='channel_id'
        row_label=Channel.find(data[row_key].to_i).channel_name()
      elsif row_key=='measure_id'
        row_label=Measure.find(data[row_key].to_i).measure_name()
      elsif row_key=='site_id'
        row_label=Site.find(data[row_key].to_i).name()
      else
        row_label=data[row_key]
      end
      if (col_key == 'dt')
        col_label=data['dtx_c']
      elsif col_key=='channel_id'
        col_label=Channel.find(data[col_key].to_i).channel_name()
      elsif col_key=='measure_id'
        col_label=Measure.find(data[col_key].to_i).measure_name()
      elsif col_key=='site_id'
        col_label=Site.find(data[col_key].to_i).name()
      else
        col_label=data[col_key]
      end
      if !table.key?(row_label)
        table[row_label]={}
        row_labels.push(row_label)
      end
      table[row_label][col_label]=data.value()
      col_labels.push(col_label)
    end
    #table.each_key {|row_label| row_labels.push row_label}
    col_labels.uniq!
    return [table,nil, col_labels, row_labels, query]
  end
  def rescue_404
    render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
  end
end
