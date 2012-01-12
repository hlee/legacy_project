class GReportsController < ApplicationController

  # To make caching easier, add a line like this to config/routes.rb:
  # map.graph "graph/:action/:id/image.png", :controller => "graph"
  #
  # Then reference it with the named route:
  #   image_tag graph_url(:action => 'show', :id => 42)

  LABEL_COUNT=3
  MULTIPLIER=1000000

  def show
    g = Gruff::Area.new

    g.title = "Gruff-o-Rama"
    
    g.data("Apples", [1, 2, 3, 4, 4, 3])
    g.data("Oranges", [4, 8, 7, 9, 8, 9])
    g.data("Watermelon", [2, 3, 1, 5, 6, 8])
    g.data("Peaches", [9, 9, 10, 8, 7, 9])

    g.labels = {0 => '2004', 2 => '2005', 4 => '2006'}

    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "gruff.png")
  end

  def alarm_trace()
    id=params['id']
    alarm=Alarm.find(id)
    if params.has_key?('small') 
      g=Gruff::Area.new('40x20')
      g.hide_legend=true
      g.hide_line_markers=true
      g.hide_title=true
      g.data("Alarm Trace", alarm.image)
      send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "alarm_trace.png")
      return
    end
    g=Gruff::Line.new('600x400')
    g.title='Alarm' 
    g.theme = {
      :colors => %w{black blue red #ffae00},
      :marker_color => '#888',
      :font_color => 'black',
      :background_colors => ['#ffffff', '#ffffff']
    }
	unit_diff=ConfigParam.find(67).val.to_i==1 ? 60 : 0
    g.data "Alarm Trace", alarm.image.collect!{|i|i+unit_diff}
    g.x_axis_label = 'Frequency (MHz)'
	
    g.y_axis_label = unit_diff==0 ? "Level (dBmV)" : "Level (dBuV)"
    begin
      center  = sprintf("%.1f", (alarm.center_frequency / 1000000).to_f)
      span    = sprintf("%.1f", (alarm.span / 1000000).to_f)
      start_f=alarm.center_frequency-alarm.span/2
      stop_f=alarm.center_frequency+alarm.span/2
      
      prof_trace=Datalog.map_data(ConfigParam.get_value(ConfigParam::StartFreq),ConfigParam.get_value(ConfigParam::StopFreq),
         start_f,stop_f,alarm.trace,500)
	  
      if ((alarm.alarm_type == Alarm::DLAvg) || (alarm.alarm_type == Alarm::DLMax))
	   prof_trace.collect!{|i|i+unit_diff}
       g.data "Datalog Profile", prof_trace
       g.title=alarm.profile.name
      else
		  
        major=prof_trace.collect {|i| i+alarm.major_offset+unit_diff}
        minor=prof_trace.collect {|i| i+alarm.minor_offset+unit_diff}
       loss_offset=alarm.loss_offset+unit_diff
       g.data "Minor", minor
       g.data "Major", major
        if alarm.loss_offset
          loss_array=Array.new(500,loss_offset)
          g.data "Link Loss", loss_array
        end
      end
      #g.data "Profile", prof.trace

      # Get some point markers to mark
      # center_frequency = center of graph
      # span = width of graph
    rescue NoMethodError => e
      g.title = "WARNING: Alarm profile not found #{e.inspect}"
      center = 120
      span = 100
    end
    label_0 = sprintf("%.1f", (center.to_f - span.to_f / 2).to_f) 
    label_1 = sprintf("%.1f", (center.to_f - span.to_f / 2 * 0.5).to_f)
    label_2 = sprintf("%.1f", (center.to_f).to_f)
    label_3 = sprintf("%.1f", (center.to_f + span.to_f / 2 * 0.5).to_f)
    label_4 = sprintf("%.1f", (center.to_f + span.to_f / 2).to_f)
    g.labels = { 
      0   => "#{label_0} MHz", 
      124 => "#{label_1} MHz", 
      249 => "#{label_2} MHz",
      374 => "#{label_3} MHz",
      499 => "#{label_4} MHz" 
    }
    img=nil
    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "alarm_trace.png")
  end
  def snapshot_trace()
    sid=params['sid']
    snapshot=Snapshot.find(sid)
    if params.has_key?('small') 
      g=Gruff::Area.new('40x20')
      g.hide_legend=true
      g.hide_line_markers=true
      g.hide_title=true
      g.data("Snapshot", snapshot.image)
      send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "alarm_trace.png")
      return
    end
    g=Gruff::Line.new('800x400')
    g.theme = {
      :colors => %w{white red blue yellow},
      :marker_color => '#888',
      :font_color => 'white',
      :background_colors => ['#111111', '#555555']
    }
    g.title="#{snapshot.site.name} __ #{snapshot.create_dt.strftime("%Y/%m/%d %H:%M")}\r\n"
    device_name=snapshot.description
    g.data(device_name, snapshot.image)
    #Get Baseline
    baseline=Snapshot.find(:first, :conditions=> {:baseline => 1, :session=>snapshot.session})
    if !baseline.nil? && (baseline.id != snapshot.id)
      g.data('baseline', baseline.image)
    end
    start=10
    stop=50
    label_0 = sprintf("%.1f", (start.to_f + 0 * ((stop - start).to_f / 4)).to_f)
    label_1 = sprintf("%.1f", (start.to_f + 1 * ((stop - start).to_f / 4)).to_f)
    label_2 = sprintf("%.1f", (start.to_f + 2 * ((stop - start).to_f / 4)).to_f)
    label_3 = sprintf("%.1f", (start.to_f + 3 * ((stop - start).to_f / 4)).to_f)
    label_4 = sprintf("%.1f", (start.to_f + 4 * ((stop - start).to_f / 4)).to_f)
    g.labels = { 
      0   => "#{label_0} MHz", 
      124 => "#{label_1} MHz", 
      249 => "#{label_2} MHz",
      374 => "#{label_3} MHz",
      499 => "#{label_4} MHz" 
    }
    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "snapshot_trace.png")
  end
  def profile_trace()
    id=params['id']
    if params.has_key?('small') 
      g=Gruff::Line.new('40x20')
      g.hide_legend=true
      g.hide_line_markers=true
      g.hide_title=true
    else
      g=Gruff::Line.new('800x400')
    end
    g.theme = {
      :colors => %w{white red blue yellow},
      :marker_color => '#888',
      :font_color => 'white',
      :background_colors => ['#111111', '#555555']
    }
    profile=Profile.find(id)
    g.title="Profile #{profile.name}"
    g.data("Profile Reference", profile.trace)
    g.data("Major Offset", profile.trace.collect {|measurement| measurement + profile.major_offset})
    g.data("Minor Offset", profile.trace.collect {|measurement| measurement + profile.minor_offset})
    if profile.link_loss
      g.data("Link Loss", profile.trace.collect {|measurement| profile.loss_offset})
    end
    start  = (ConfigParam.get_value(ConfigParam::StartFreq) / 1000000).to_f
    start  = (ConfigParam.get_value(ConfigParam::StartFreq) / 1000000).to_f
    stop   = (ConfigParam.get_value(ConfigParam::StopFreq)  / 1000000).to_f
    label_0 = sprintf("%.1f", (start.to_f + 0 * ((stop - start).to_f / 4)).to_f)
    label_1 = sprintf("%.1f", (start.to_f + 1 * ((stop - start).to_f / 4)).to_f)
    label_2 = sprintf("%.1f", (start.to_f + 2 * ((stop - start).to_f / 4)).to_f)
    label_3 = sprintf("%.1f", (start.to_f + 3 * ((stop - start).to_f / 4)).to_f)
    label_4 = sprintf("%.1f", (start.to_f + 4 * ((stop - start).to_f / 4)).to_f)
    g.labels = { 
      0   => "#{label_0} MHz", 
      124 => "#{label_1} MHz", 
      249 => "#{label_2} MHz",
      374 => "#{label_3} MHz",
      499 => "#{label_4} MHz" 
    }
    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "profile_trace.png")
  end

  def data_log_trace()
    #Handle selected port
    if (params.key?("site_id"))
      #Get selected port
      site_id=params['site_id']
    end
    #Set Time Range
    start_ts=Time.at(params['time1'].to_i)
    stop_ts=Time.at(params['time2'].to_i)
    #Set Frequency Range
    start_freq=params['freq1'].to_i*MULTIPLIER
    stop_freq=params['freq2'].to_i*MULTIPLIER
    overtime_flag=params['overtime']=='on'
    #Set Label List
    labels={}

    #Get Data 
    datalog=Datalog.summarize_datalogs(
      {
          :site_id=>site_id, 
          :start_ts=>start_ts,
          :stop_ts=>stop_ts,
          :start_freq=>start_freq,
          :stop_freq=>stop_freq,
      },
      overtime_flag
    )

    #Build frequency labels
    sample_count=datalog[:avg].length()-1
    center_frequency=(stop_freq-start_freq)/2+start_freq

    if ((LABEL_COUNT % 2) !=1) || (LABEL_COUNT < 0)
      raise ("Label Count must be a positive odd number") 
    end
    time_format="%Y-%m-%d %H:%M"
    x_label=''
    if (!overtime_flag)
      if LABEL_COUNT == 1
        labels[(sample_count/2).to_i]=(center_frequency/MULTIPLIER).to_s + "_MHz"
      else
        increment_freq=(stop_freq-start_freq)/(LABEL_COUNT-1)
        (LABEL_COUNT).times { |idx|
          sample_idx=(sample_count.to_f/(LABEL_COUNT-1).to_f*idx).ceil
          label=((idx*increment_freq+start_freq)/MULTIPLIER).to_s+"_MHz"
          labels[sample_idx]=label
        }
      end
      x_label='Frequency'
      datalog[:max]=Datalog::map_data(Datalog::STORED_START_FREQ,
        Datalog::STORED_STOP_FREQ, start_freq, stop_freq,datalog[:max],500)
      datalog[:min]=Datalog::map_data(Datalog::STORED_START_FREQ,
        Datalog::STORED_STOP_FREQ, start_freq, stop_freq,datalog[:min],500)
      datalog[:avg]=Datalog::map_data(Datalog::STORED_START_FREQ,
        Datalog::STORED_STOP_FREQ, start_freq, stop_freq,datalog[:avg],500)
    else
      if LABEL_COUNT == 1
        raise ("Label Count must be > 1") 
      else
        seconds_diff=stop_ts.to_i-start_ts.to_i
        increment_ts=seconds_diff/(LABEL_COUNT-1)
        (LABEL_COUNT+1).times { |idx|
          sample_idx=(sample_count.to_f/(LABEL_COUNT).to_f*idx).ceil
          if (seconds_diff <60*60*10) #Less than 10 hours
            label="#{((datalog[:time][sample_idx]-start_ts.to_i) / 60).to_i}"
            x_label='Time (Minutes)'
          elsif (seconds_diff <60*60*24*7) #Less than 7 days
            label="#{((datalog[:time][sample_idx]-start_ts.to_i) / (60*60)).to_i} - #{sample_idx}"
            x_label='Time (Hours)'
          else
            label="#{((datalog[:time][sample_idx]-start_ts.to_i) / (60*60*24)).to_i}"
            x_label='Time (Days)'
          end
          labels[sample_idx]=label
        }
      end
    end

    #Build Graph
    id=params['id']
    g=Gruff::Area.new('800x400')
    title="Data Trace  #{start_ts.strftime(time_format)} thru #{stop_ts.strftime(time_format)}"# #{span} #{center_frequency} #{sample_count}
    g.title=title
    g.title_font_size=20
    g.labels=labels
    g.x_axis_label=x_label
    g.y_axis_label='dBmV'
    g.legend_font_size=15
    g.marker_count=7
    #raise(start_freq.to_s)
    g.data("DataLog Trace",datalog[:avg],'#0000c0')
    g.data("Maximum Trace", datalog[:max],'#c00000')
    g.data("Minimum Trace", datalog[:min],'#c0c000')
    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "alarm_trace.png")
  end

  def alarm_trace_tag()
    @alarm_id=params['id']
    #send_data("<img src=/g_reports/alarm_trace?id=#{id}>", :disposition => 'inline', :type => 'image/png', :filename => "alarm_trace.png")
  end
  def profile_trace_tag()
    @profile_id=params['id']
    #send_data("<img src=/g_reports/alarm_trace?id=#{id}>", :disposition => 'inline', :type => 'image/png', :filename => "alarm_trace.png")
  end
  def snapshot_trace_tag()
    @snapshots=params['snapshots']
  end

  def graph_measurements()
    table,err,col_labels,row_labels=_meas_filter(session[:filter_params])
    if !err.nil?
      flash[:notice]=err
      render :action => "display_error"
      return
    end
    g=Gruff::Line.new('800x400')

    row_count=row_labels.length()
    g.title="Measurement "<< row_count.to_s
    col_labels.each { |col_label|
      g.data(col_label, row_labels.collect {|row_label| table[row_label][col_label]})
    }
    ratio=1
    if (row_count > 5)
      ratio=row_count.to_f/5.0
    end
    g.title=" "<< ratio.to_s
    pos=0
    g.title="Measurement Graph "
    data_labels={}
    while (row_count > pos)
      data_labels[pos.to_i]=row_labels[pos.to_i]
      pos+=ratio
    end
    data_labels[row_count-1]=row_labels[-1]
    g.labels=data_labels
    send_data(g.to_blob, :disposition => 'inline', :type => 'image/png')
  end

  def graph_measurements_tag()
    url=url_for(:view=>'graph_measurements', :controller=>"g_reports")

    #send_data("<img src=\"/g_reports/graph_measurements\">", :disposition => 'inline', :type => 'image/png', :filename => "measurement.png")
    #send_data("-#{session[:filter_params]}-", :disposition => 'inline', :type => 'image/png', :filename => "measurement.png")
  end
end
