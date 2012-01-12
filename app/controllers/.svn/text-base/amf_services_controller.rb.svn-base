require 'date'

class AmfServicesController < ApplicationController

###################################
## Downstream Configuration
###################################
	# loadTestPlan(id:int)
  def load_test_plan(analyzer_id=nil)
    puts params.inspect()
    if (analyzer_id.nil?)
      if params.key?("analyzer_id") && (!params["analyzer_id"].nil?) #For Web browser test
        analyzer_id=params["analyzer_id"]
      elsif !params.key?(0) #For AMF Request Test
        raise("Analyzer ID is required")
      else
        analyzer_id=params[0]
      end
    end
    analyzer=Analyzer.find(analyzer_id)
    results=[]
    analyzer.cfg_channels.each { |ch|
      cfgch={"channel"=> {},"tests"=>[]}
      cfgch["channel"]["name"]=ch.channel_name
      cfgch["channel"]["channel"]=ch.channel
      cfgch["channel"]["system_file"]=ch.system_file_name
      cfgch["channel"]["freq"]=ch.freq
      cfgch["channel"]["polarity"]=ch.polarity
      cfgch["channel"]["modulation"]=ch.modulation
      cfgch["channel"]["symbol_rate"]=ch.symbol_rate
      cfgch["channel"]["bandwidth"]=ch.bandwidth
      cfgch["channel"]["audio1_offset"]=ch.audio_offset1
      cfgch["channel"]["audio2_offset"]=ch.audio_offset2
      cfgch["channel"]["annex"]=ch.annex
      cfgch["tests"]=[]
      ch.cfg_channel_tests.each { |cfgtst|
        tstobj={}
        tstobj["port_id"]=cfgtst.switch_port_id
        tstobj["MER"]=cfgtst.mer_nominal       
        tstobj["MER_ENABLE_FLAG"]=cfgtst.mer_flag  
        tstobj["MER_MINOR"]=cfgtst.mer_minor         
        tstobj["MER_MAJOR"]=cfgtst.mer_major         
        tstobj["PRE_BER"]=cfgtst.preber_nominal    
        tstobj["PRE_BER_ENABLE_FLAG"]=cfgtst.preber_flag
        tstobj["PRE_BER_MINOR"]=cfgtst.preber_minor      
        tstobj["PRE_BER_MAJOR"]=cfgtst.preber_major      
        tstobj["POST_BER"]=cfgtst.postber_nominal   
        tstobj["POST_BER_ENABLE_FLAG"]=cfgtst.postber_flag
        tstobj["POST_BER_MINOR"]=cfgtst.postber_minor     
        tstobj["POST_BER_MAJOR"]=cfgtst.postber_major     
        tstobj["VIDEO_LVL"]=cfgtst.video_lvl_nominal 
        tstobj["VIDEO_LVL_ENABLE_FLAG"]=cfgtst.video_lvl_flag
        tstobj["VIDEO_LVL_MINOR"]=cfgtst.video_lvl_minor   
        tstobj["VIDEO_LVL_MAJOR"]=cfgtst.video_lvl_major   
        tstobj["VARATIO"]=cfgtst.varatio_nominal   
        tstobj["VARATIO_ENABLE_FLAG"]=cfgtst.varatio_flag
        tstobj["VARATIO_MINOR"]=cfgtst.varatio_minor
        tstobj["VARATIO_MAJOR"]=cfgtst.varatio_major
        
        tstobj["MEASURED_VIDEO_FREQ"] = cfgtst.mvf_nominal
        tstobj["MEASURED_VIDEO_FREQ_ENABLE_FLAG"] = cfgtst.mvf_flag
        tstobj["MEASURED_VIDEO_FREQ_MAJOR"] = cfgtst.mvf_major
        tstobj["MEASURED_VIDEO_FREQ_MINOR"] = cfgtst.mvf_minor
        tstobj["MEASURED_AUDIO_FREQ"] = cfgtst.maf_nominal
        tstobj["MEASURED_AUDIO_FREQ_ENABLE_FLAG"] = cfgtst.maf_flag
        tstobj["MEASURED_AUDIO_FREQ_MAJOR"] = cfgtst.maf_major
        tstobj["MEASURED_AUDIO_FREQ_MINOR"] = cfgtst.maf_minor

        tstobj["DCP"]=cfgtst.dcp_nominal       
        tstobj["DCP_ENABLE_FLAG"]=cfgtst.dcp_flag
        tstobj["DCP_MINOR"]=cfgtst.dcp_minor         
        tstobj["DCP_MAJOR"]=cfgtst.dcp_major         
        tstobj["ENM"]=cfgtst.enm_nominal    
        tstobj["ENM_ENABLE_FLAG"]=cfgtst.enm_flag   
        tstobj["ENM_MINOR"]=cfgtst.enm_minor      
        tstobj["ENM_MAJOR"]=cfgtst.enm_major      
        tstobj["EVM"]=cfgtst.evm_nominal    
        tstobj["EVM_ENABLE_FLAG"]=cfgtst.evm_flag   
        tstobj["EVM_MINOR"]=cfgtst.evm_minor     
        tstobj["EVM_MAJOR"]=cfgtst.evm_major
             
        tstobj["MER_FREQ"]=cfgtst.mer_freq     
        tstobj["PRE_BER_FREQ"]=cfgtst.preber_freq     
        tstobj["POST_BER_FREQ"]=cfgtst.postber_freq
        tstobj["VIDEO_LVL_FREQ"]=cfgtst.video_lvl_freq
        tstobj["VARATIO_FREQ"]=cfgtst.varatio_freq
        tstobj["ENM_FREQ"]=cfgtst.enm_freq
        tstobj["EVM_FREQ"]=cfgtst.evm_freq    
        tstobj["DCP_FREQ"]=cfgtst.dcp_freq
        tstobj["MEASURED_VIDEO_FREQ_FREQ"]=cfgtst.mvf_freq    
        tstobj["MEASURED_AUDIO_FREQ_FREQ"]=cfgtst.maf_freq    
        cfgch["tests"].push(tstobj);
      }
      results.push(cfgch)
    }
    respond_to do |format|
      format.xml { render :xml => results }
      format.amf { render :amf => results } 
    end
  end

	# saveTestPlan(data:ArrayCollection, analyzerId:int)
  def save_test_plan
    puts "Im in The Save Test Plan"
    puts params.inspect()
    analyzer=Analyzer.find(params[1].to_i)
    analyzer.cfg_channels.each { |cfgch|
      puts cfgch.id
      CfgChannel.destroy(cfgch.id)
    }
    testplan=params[0]
    testplan.each {|ch|
      cc=analyzer.cfg_channels.new()
      puts ch.inspect
      cc.channel_name=ch["channel"]["name"]
      cc.system_file_name =ch["channel"]["system_file"]
      cc.channel=ch["channel"]["number"]
      cc.channel_name =ch["channel"]["name"]
      cc.freq =ch["channel"]["frequency"]
      cc.polarity =ch["channel"]["polarity"]
      cc.modulation   =ch["channel"]["modulation"]
      cc.symbol_rate  =ch["channel"]["symbol_rate"] || 0
      cc.bandwidth =ch["channel"]["bandwidth_entry"]*1000000
      cc.audio_offset1 = ch["channel"]["audio1_offset"] || 0
      cc.audio_offset2 = ch["channel"]["audio2_offset"] || 0
      cc.annex = ch["channel"]["annex"] || 0
      #cc.save
      result= cc.save 
	  
	  
      ch["tests"].each { |tst|
        cfgtst=cc.cfg_channel_tests.new()
        if (!tst.key?("port") || tst["port"].nil? || !tst["port"].key?("port_id"))
        
           cfgtst.switch_port_id=nil
        
        else
           cfgtst.switch_port_id=tst["port"]["port_id"]
        end
        cfgtst.mer_nominal       =tst["MER"]
        cfgtst.mer_flag          =tst["MER_ENABLE_FLAG"] || false
        cfgtst.mer_minor         =tst["MER_MINOR"]
        cfgtst.mer_major         =tst["MER_MAJOR"]
        cfgtst.preber_flag       =tst["PRE_BER_ENABLE_FLAG"] || false
        cfgtst.preber_nominal    =tst["PRE_BER"]
        cfgtst.preber_minor      =tst["PRE_BER_MINOR"]
        cfgtst.preber_major      =tst["PRE_BER_MAJOR"]
        cfgtst.postber_nominal   =tst["POST_BER"]
        cfgtst.postber_flag      =tst["POST_BER_ENABLE_FLAG"] || false
        cfgtst.postber_minor     =tst["POST_BER_MINOR"]
        cfgtst.postber_major     =tst["POST_BER_MAJOR"]
        cfgtst.video_lvl_nominal =tst["VIDEO_LVL"]
        cfgtst.video_lvl_flag    =tst["VIDEO_LVL_ENABLE_FLAG"] || false
        cfgtst.video_lvl_minor   =tst["VIDEO_LVL_MINOR"]
        cfgtst.video_lvl_major   =tst["VIDEO_LVL_MAJOR"]
        cfgtst.varatio_nominal   =tst["VARATIO"]
        cfgtst.varatio_flag      =tst["VARATIO_ENABLE_FLAG"] || false
        cfgtst.varatio_minor     =tst["VARATIO_MINOR"]
        cfgtst.varatio_major     =tst["VARATIO_MAJOR"]
        
        cfgtst.mvf_nominal			 =tst["MEASURED_VIDEO_FREQ"]
        cfgtst.mvf_flag          =tst["MEASURED_VIDEO_FREQ_ENABLE_FLAG"] || false
        cfgtst.mvf_major         =tst["MEASURED_VIDEO_FREQ_MAJOR"]
        cfgtst.mvf_minor         =tst["MEASURED_VIDEO_FREQ_MINOR"]
        cfgtst.maf_nominal       =tst["MEASURED_AUDIO_FREQ"]
        cfgtst.maf_flag          =tst["MEASURED_AUDIO_FREQ_ENABLE_FLAG"] || false
        cfgtst.maf_major         =tst["MEASURED_AUDIO_FREQ_MAJOR"]
        cfgtst.maf_minor         =tst["MEASURED_AUDIO_FREQ_MINOR"]

        cfgtst.dcp_nominal       =tst["DCP"]
        cfgtst.dcp_flag          =tst["DCP_ENABLE_FLAG"] || false
        cfgtst.dcp_minor         =tst["DCP_MINOR"]
        cfgtst.dcp_major         =tst["DCP_MAJOR"]
        cfgtst.enm_nominal       =tst["ENM"]
        cfgtst.enm_flag          =tst["ENM_ENABLE_FLAG"] || false
        cfgtst.enm_minor         =tst["ENM_MINOR"]
        cfgtst.enm_major         =tst["ENM_MAJOR"]
        cfgtst.evm_flag          =tst["EVM_ENABLE_FLAG"] || false
        cfgtst.evm_nominal       =tst["EVM"]
        cfgtst.evm_minor         =tst["EVM_MINOR"]
        cfgtst.evm_major         =tst["EVM_MAJOR"]
        
        cfgtst.mer_freq          =(tst["MER_FREQ"].nil?? 1:tst["MER_FREQ"])
        cfgtst.preber_freq       =(tst["PRE_BER_FREQ"].nil?? 1:tst["PRE_BER_FREQ"])
        cfgtst.postber_freq      =(tst["POST_BER_FREQ"].nil?? 1:tst["POST_BER_FREQ"])
        cfgtst.video_lvl_freq    =(tst["VIDEO_LVL_FREQ"].nil?? 1:tst["VIDEO_LVL_FREQ"])
        cfgtst.varatio_freq      =(tst["VARATIO_FREQ"].nil?? 1:tst["VARATIO_FREQ"])
        cfgtst.enm_freq          =(tst["ENM_FREQ"].nil?? 1:tst["ENM_FREQ"])
        cfgtst.evm_freq          =(tst["EVM_FREQ"].nil?? 1:tst["EVM_FREQ"])
        cfgtst.dcp_freq          =(tst["DCP_FREQ"].nil?? 1:tst["DCP_FREQ"])
        cfgtst.mvf_freq          =(tst["MEASURED_VIDEO_FREQ_FREQ"].nil?? 1:tst["MEASURED_VIDEO_FREQ_FREQ"])
        cfgtst.maf_freq          =(tst["MEASURED_AUDIO_FREQ_FREQ"].nil?? 1:tst["MEASURED_AUDIO_FREQ_FREQ"])
        cfgtst.save
      }

    }
  end

	# getTestPlanData(id:int)
  def get_test_plan_data(test_plan_id=nil)
    if (test_plan_id.nil?)
      if params.key?("test_plan_id") && (!params["test_plan_id"].nil?) #For Web browser test
        test_plan_id=params["test_plan_id"]
      elsif !params.key?(0) #For AMF Request Test
        raise("Analyzer ID is required")
      else
        test_plan_id=params[0]
      end
    end
    
    logger.debug "Get Test Plan Data"
    begin
      sftp=SfTestPlan.find(test_plan_id)
      channels=sftp.sf_test_channels.collect { |stc|
        freq= stc.sf_channel.freq()
        if (!stc.sf_channel.channel_dtls.key?("modulation"))
           raise stc.sf_channel.channel_dtls.inspect
        end
        channel_type = stc.sf_channel.channel_type
        va1 = (channel_type.to_i == 0) ? stc.sf_channel.channel_dtls["va1sep"]  : ""
        va2 = (channel_type.to_i == 0) ? stc.sf_channel.channel_dtls["va2sep"]  : ""
        symbol_rate = stc.sf_channel.channel_dtls["symbolrate"] 
        annex = (channel_type.to_i == 1) ?  stc.sf_channel.channel_dtls["j83annex"] : ""
        polarity = stc.sf_channel.channel_dtls["polarity"]
        {  :channel_nbr => stc.sf_channel.channel_number,
           :frequency => stc.sf_channel.freq(),
           :channel_name => stc.sf_channel.channel_name,
           :channel_type => channel_type,
           :direction => stc.sf_channel.direction,
           :modulation => stc.sf_channel.modstr(),
           :bandwidth => stc.sf_channel.channel_dtls["bandwidth"],
           :va1 => va1,
           :va2 => va2,
           :symbol_rate => symbol_rate,
           :annex => annex,
           :polarity => polarity
        }
      }
      tests={}
      orig_tests=[]
      sftp.sf_system_tests.each { |sst|
        meas=Measure.find(:first,:conditions=> {:sf_meas_ident=>sst.test_type})
        if !meas.nil?
           tests[meas.measure_name.upcase+"_ENABLE_FLAG"] = sst.enable_flag
           if (meas.check_max_flag && meas.check_min_flag)
             diff=sst.max_value.to_f-sst.min_value.to_f
             nominal=sst.min_value.to_f + diff/2
             tests[meas.measure_name.upcase]=nominal
             tests[meas.measure_name.upcase+"_MAJOR"]=diff/2
             tests[meas.measure_name.upcase+"_MINOR"]=diff/2-sst.tolerance.to_f
             tests[meas.measure_name.upcase+"_TESTTYPE"]=sst.test_type
             tests[meas.measure_name.upcase+"_FREQ"]=1
           end
           if (!meas.check_max_flag && meas.check_min_flag)
             nominal=meas.sanity_max.to_f
             tests[meas.measure_name.upcase]=nominal
             tests[meas.measure_name.upcase+"_MAJOR"]=nominal-sst.min_value.to_f
             tests[meas.measure_name.upcase+"_MINOR"]=nominal-sst.min_value.to_f-sst.tolerance.to_f
             tests[meas.measure_name.upcase+"_TESTTYPE"]=sst.test_type
             tests[meas.measure_name.upcase+"_FREQ"]=1
           end
           if (meas.check_max_flag && !meas.check_min_flag)
             nominal=meas.sanity_min.to_f
             if (meas.exp_flag)
             	nominal=0
             end
             tests[meas.measure_name.upcase]=nominal
             tests[meas.measure_name.upcase+"_MAJOR"]=-nominal+sst.max_value.to_f
             tests[meas.measure_name.upcase+"_MINOR"]=-nominal+sst.max_value.to_f-sst.tolerance.to_f
             tests[meas.measure_name.upcase+"_TESTTYPE"]=sst.test_type
             tests[meas.measure_name.upcase+"_FREQ"]=1
           end
           orig_tests.push({:test => {:system_test => sst, :measure => meas}})
        end
      }
     #testplanlist=[{:channels=>channels,:tests=>tests, :orig_tests=>orig_tests}]
     testplanlist={:channels=>channels,:tests=> tests}
      
    rescue ActiveRecord::RecordNotFound => recnotfound
      raise "A record was not found"
    end
    
    respond_to do |format|
      format.xml { render :xml => testplanlist }
      format.amf { render :amf => testplanlist } 
    end
  end
  
  # measureCommand(data:Object)
  def measure_command(analyzer_id=nil)
    if (analyzer_id.nil?)
      if params.key?("analyzer_id") && (!params["analyzer_id"].nil?) #For Web browser test
        analyzer_id=params["analyzer_id"]
        query_params=params
      elsif !params.key?(0) || !params[0].key?("analyzer_id") || (params[0]["analyzer_id"].nil?) #For AMF Request Test
        raise("Analyzer ID is required")
      else
        analyzer_id=params[0]["analyzer_id"]
        query_params=params[0]
      end
    end
    daemon_query=""
    daemon_query_arr=[]
    query_params.delete('action')
    query_params.delete('controller')
    query_params.keys.each {|ky|
      daemon_query_arr.push("#{ky}=#{query_params[ky]}")
    }
    daemon_query=daemon_query_arr.join('&')
    anl=Analyzer.find(analyzer_id)
    anl.processing = Time.now
    anl.save
    anl.clear_exceptions()
    anl.clear_progress()
    logger.debug("In Send Command for MEASURE")
    port=anl.cmd_port
    logger.debug("Got response from master")
    anl.status=Analyzer::PROCESSING
    anl.save()
    logger.debug("Set analyzer to processing")
    begin
       url="http://localhost:#{port}/MEASURE?#{daemon_query}"

       response=Net::HTTP.get(URI(url))
       logger.debug response.inspect
    rescue
    end
    result={}
    logger.debug url.inspect
    logger.debug response.inspect
    if (response.nil?)
       result[:message]="Not getting responses from monitoring daemon"
       result["status"]="FAIL"
    elsif response =~ /FAIL:(.*)/
       result[:message]=$1
       result["status"]="FAIL"
    else
       data=response.split(';')
       data.each{ |item|
         (key,value)=item.split('=')
         result[key]=value.to_f
       }
    end
    respond_to do |format|
      format.xml { render :xml => result }
      format.amf { render :amf => result } 
    end
  end
  
  # getSystemFileList()
  def get_system_file_list
    logger.debug "System File List"
     sflist=SfSystemFile.find(:all).collect {|sf| 
          {
            :system_file_id=>sf[:id],
            :display_name=>sf.display_name, 
            :test_plans=>sf.sf_test_plans.collect{|tp| 
              {
                :test_plan_id=>tp[:id],
                :test_plan_name=>tp[:name]
              }
            }
         }
    }
    respond_to do |format|
      format.xml { render :xml => sflist }
      format.amf { render :amf =>  sflist } 
    end
  end
  
  # getAnalyzerList()
  def get_analyzer_list
    analyzer_list=Analyzer.find(:all).collect {|anl|
      {:analyzer_id => anl.id, :analyzer_name => anl.name}
    }
    
    respond_to do |format|
      format.xml { render :xml => analyzer_list }
      format.amf { render :amf => analyzer_list } 
    end
  end
  
  # getPortList(analyzerId:int)
  def get_port_list(analyzer_id=nil)
    if (analyzer_id.nil?)
      if params.key?("analyzer_id") && (!params["analyzer_id"].nil?) #For Web browser test
        analyzer_id=params["analyzer_id"]
      elsif !params.key?(0)  #For AMF Request Test
        raise("Analyzer ID is required")
      else
        analyzer_id=params[0]
      end
    end
    begin
      analyzer=Analyzer.find(analyzer_id)
      switch_ports=[]
      analyzer.switches.each { |sw|
        sw.switch_ports.each { |sp|
          if sp.purpose == 2
	    switch_ports.push({
              :port_id=>sp.id,
	      :port_name=>sp.name,
	      :site=>sp.site.name
	      })
          end
	}
      }
    rescue ActiveRecord::RecordNotFound => recnotfound
      raise "A record was not found"
    end
    respond_to do |format|
      format.xml { render :xml => switch_ports }
      format.amf { render :amf => switch_ports } 
    end
  end

	# no use in flex now
  def get_test_plan_items(test_plan_id=nil)
    if test_plan_id.nil?
      if params.key?("test_plan_id") && (!params["test_plan_id"].nil?) #For Web browser test
        test_plan_id=params["test_plan_id"]
      elsif !params.key?(0) || !params.key?("test_plan_id") || (params["test_plan_id"].nil?) 
        raise("Test Plan ID is required")
      else
        test_plan_id=params[0]["test_plan_id"]
      end
    end
    begin
      sf_test_plan=SfTestPlan.find(test_plan_id.to_i)
    rescue ActiveRecord::RecordNotFound => recnotfound
      raise "Test Plan Unknown"
    end
    if (sf_test_plan.nil?)
      raise("Test Plan ["+test_plan_id+"] Not Known")
    end
    logger.debug "Getting Test Plan for :" + test_plan_id.to_s
    sfchannels=sf_test_plan.sf_test_channels.collect { |sfc|
      { 
        :number => sfc.sf_channel.channel_number,
        :name => sfc.sf_channel.channel_name,
        :chtype => sfc.sf_channel.channel_type,
        :direction => sfc.sf_channel.direction,
        :freq => sfc.sf_channel.display_frequency,
        :dtls => sfc.sf_channel.channel_dtls
    }
    }
    testplan= [{ :sfchannels => sfchannels}]
    respond_to do |format|
      format.xml { render :xml => sfchannels }
      format.amf { render :amf => testplan }
    end
  end

##################################
## Upstream Channels for datalog/historical ingress viewer.
##################################

	# getUpstreamChannels()
  def get_upstream_channels
    logger.debug "Upstream1 Channels"
    upstream_channels=UpstreamChannel.find(:all)
    logger.debug "Upstream Channels2"
    chlist=upstream_channels.collect {|ch| {:freq=>ch.freq, :bandwidth => ch.bandwidth, :name => ch.name}}
    logger.debug "Upstream Channels3"
    logger.debug upstream_channels.inspect()
    respond_to do |format|
      format.html
      format.xml { render :xml => chlist.to_x }
      format.amf { 
        logger.debug "Returning upstream_channels"
        logger.debug "Returning #{upstream_channels}"
        render :amf =>  chlist
      }
    end
  end
  
  # getUom()
  def get_uom()
  #1 stand for dBuV
  #2 stand for dBmV   
    uom=ConfigParam.find(67).val.to_i
    respond_to do |format|
      format.html
      format.xml { render :xml => uom.to_x }
      format.amf { 
        logger.debug "Returning uom"
        logger.debug "Returning #{uom}"
        render :amf => uom 
      }
	  end
  end
  
  # getLinkAnalyzers()
  def get_link_analyzers
    result=Analyzer.get_link_analyzers
    respond_to do |format|
      format.html
      format.xml { render :xml => result }
      format.amf { 
        logger.debug "JerryK=>Returning"
        render :amf => result 
      }
		end
  end 

	# disconnectAnalyzer(id:int)
  def disconnect_analyzer(ana_id=nil)
    if ana_id.nil?
		  if params.key?(0)
		    ana_id=params[0]
			an=Analyzer.find(ana_id)
			an.update_attributes(:auto_mode=>"3",:att_count=>"-1")
			an.check_disconnect_analyzer
		  else
	        raise "No analyzer id "	  
		  end
		end
		respond_to do |format|
      format.html
      format.xml { render :xml => Analyzer.find(ana_id).status }
      format.amf { 
        render :amf => Analyzer.find(ana_id).status 
      }
		end
  end
  
  # checkAnalyzer(id:int)
  def check_analyzer(ana_id=nil)
    result=false
    if ana_id.nil?
		  if params.key?(0)
		    ana_id=params[0]
		  else
	        raise "No analyzer id "	  
		  end
		end
		respond_to do |format|
	      format.html
	      format.xml { render :xml => Analyzer.find(ana_id).status }
	      format.amf { 
	        render :amf => Analyzer.find(ana_id).status 
	      }
		end
  end
  
  #######################
  # Instrument/Network configuration services
  #######################
  
  # getSites(type:int)
  def get_sites(site_type=nil)
    logger.debug "Inside Get Sites of AMF controller"
    if site_type.nil?
       if params.key?(0) 
         site_type=params[0]
       else
         raise "No site passed because #{params.length} and #{params[0].key?("site_type")} to get_sites #{params.inspect()}"
       end
    end
		site_list=Site.data_sites(site_type)
    respond_to do |format|
      format.html
      format.xml { render :xml => site_list.to_x }
      format.amf { 
        logger.debug "Returning site_list"
        logger.debug "Returning #{site_list}"
        render :amf => site_list 
      }
    end
  end
  
  # getMeasures()
  def get_measures
    measure_list = Measure.find(:all)
    respond_to do |format|
      format.html
      format.xml { render :xml => measure_list.to_x }
      format.amf { 
        logger.debug "Returning measure_list"
        logger.debug "Returning #{measure_list}"
        render :amf => measure_list 
      }
    end
  end
  
  # getDateRange(siteId:int)
  def get_date_range(site_id=nil)
   logger.error "get_data_range_jerry"
    if (site_id.nil?)
      if params.length > 0
        site_id=params[0]
      else
        raise "No Site Specified"
      end
    end
    stop_dtime=Measurement.maximum(:dt,:conditions=>["site_id=?",site_id])
    if stop_dtime.nil?
    	result=[]
    end
    stop_dt=DateTime.new(stop_dtime.year, stop_dtime.month, stop_dtime.day,23,59,59)
    if stop_dt.nil?
    	result= []
    end
    start_dtime=Measurement.minimum(:dt,:conditions=>["site_id=?",site_id])
    if start_dtime.nil?
    	result= []
    end
    #start_dt=DateTime.new(start_dtime.year, start_dtime.month, start_dtime.day)
    start_dt=start_dtime
    if start_dt.nil?
    	result= []
    end
    result= [start_dt,stop_dt]
    respond_to do |format|
      format.html
      format.xml { render :xml => result.to_x }
      format.amf { 
        logger.debug "Returning result"
        logger.debug "Returning #{result}"
        render :amf => result 
      }
    end
	end
	
	# getMeasurements(siteId:int, measureIds:Array, channelIds:Array, start:String, stop:String)
  def get_measurements
    logger.debug params.length
    result=nil
    if params.length >= 5
      site_id=params[0]
      measureList=params[1]
      channelList=params[2]
      start_dt=params[3]
      stop_dt=params[4]
      result=_get_measurements(site_id,
        measureList, channelList,start_dt, stop_dt)
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => result.to_x }
      format.amf { 
        logger.debug "Returning result"
        logger.debug "Returning #{result}"
        render :amf => result 
      }
    end
  end
  
  # internal function
  def _get_measurements(site_id, measureList, channelList, start_dt, stop_dt)
    result=[]
    #Build measurement query
    cond_str="site_id=? and measure_id=? and channel_id=? and dt between ? and ?"
    filter=_gen_filter(measureList, "measurements.measure_id") + ((channelList.length > 0) ? (" and " + _gen_filter(channelList,"measurements.channel_id")) : "")
    sql_query="select measurements.channel_id, measurements.measure_id,round(min(IFNULL(min_value,value)),measures.dec_places)as min, round(avg(value),measures.dec_places) as avg, round(max(IFNULL(max_value,value)),measures.dec_places) as max, " +
      "measurements.min_limit as min_limit , measurements.max_limit as max_limit " +
      "from measures  left join measurements on (measures.id=measurements.measure_id) " +
      "where measurements.site_id=#{site_id} and dt between \"#{start_dt}\" and \"#{stop_dt}\" and (#{filter}) and measurements.measure_id=measures.id " + #search params
      "group by measurements.channel_id,measurements.measure_id order by measurements.channel_id, measurements.measure_id"
    data=Measurement.find_by_sql(sql_query)
    curr_chid=nil
    mins=[]
    maxs=[]
    avgs=[]
    meas=[]
    min_limits=[]
    max_limits=[]
    #reorganize records chanel/measure records to be an array of arrays.
    #cells in the inner array are per measure id
    #The cells in the outer array are per channel id.
    data.each { |rec|
      if curr_chid != rec.channel_id #If the channel channges.
        if (!curr_chid.nil?) #If this is not the first channel.
          #Store off the current channel measures and restart
          res = {}
          res[:min]=mins
          res[:max]=maxs
          res[:avg]=avgs
          res[:measure_id]=meas
          res[:channel_id]=curr_chid
          ch=Channel.find(curr_chid)
          if (ch.nil?)
             res[:channel_freq]=0
          else
             res[:channel_freq]=ch.channel_freq
          end
          res[:min_limit]=min_limits
          res[:max_limit]=max_limits
          result.push(res)
          mins=[]
          maxs=[]
          avgs=[]
          meas=[]
          min_limits=[]
          max_limits=[]
        end
      end
      mins.push(rec.min)
      maxs.push(rec.max)
      avgs.push(rec.avg)
      meas.push(rec.measure_id)
      curr_chid=rec.channel_id
      min_limits.push(rec.min_limit)
      max_limits.push(rec.max_limit)
      measure_obj=Measure.find(rec.measure_id)
      meas_ident=measure_obj.sf_meas_ident
    }
    #For the last channel
    res = {}
    res[:min]=mins
    res[:max]=maxs
    res[:avg]=avgs
    res[:measure_id]=meas
    res[:channel_id]=curr_chid
    logger.debug("CURR CHID #{curr_chid}")
    if !curr_chid.nil?
      ch=Channel.find(curr_chid)
      if (ch.nil?)
         res[:channel_freq]=0
      else
         res[:channel_freq]=ch.channel_freq
      end
    else
      res[:channel_freq]=curr_chid
    end
    res[:min_limit]=min_limits
    res[:max_limit]=max_limits
    result.push(res)
    logger.debug result.inspect()
    return result
  end
  
  ##################
  # Get SLM Summary
  ##################
  
  # getSlmSummary(siteId:int, channelIds:Array, start:String, stop:String)
  def get_slm_summary()

    site_id=params[0]
    channel_list=params[1]
    start_dt=params[2]
    stop_dt=params[3]
   
    #channel_list=Channel.find(:all, :order => "channel_freq").collect { |ch| ch.id}
    #puts channel_list.inspect()
    if start_dt.nil?
      start_dt=Measurement.min(dt).strftime('%F %T')
    end
    if stop_dt.nil?
      stop_dt=Measurement.min(dt).strftime('%F %T')
    end
    measure_list=[9,11,17]
    result=_get_measurements(site_id, measure_list, channel_list, start_dt, stop_dt)
    respond_to do |format|
      format.html
      format.xml { render :xml => result.to_x }
      format.amf { 
        logger.debug "Returning result"
        logger.debug "Returning #{result}"
        render :amf => result 
      }
    end
  end
  
	# getConstellation(channelId:int, siteId:int, startDate:Date, stopDate:Date)
  def get_constellation
=begin
    channel_id=params[0]
    site_id=params[1]
		start_ts=params[2]
		stop_ts=params[3]+86399 
#		logger.error "start_ts equal #{params[2]} stop_ts equal #{params[3]}"
		
		channel=Channel.find(channel_id)
		freq=channel.channel_freq
		modulation=channel.modulation
		
		logger.error "freq equal #{freq}"
                sql_query = "select sumconstellation(image_data) as sumct from constellations where site_id = ? and dt > ? and dt < ? and freq = ?"
                matrix1 = Constellation.find_by_sql([sql_query, site_id,start_ts,stop_ts,freq])
                matrix=matrix1[0][:sumct].unpack("i*")
		result={}
		result[:modulation]=modulation
		result[:matrix]=matrix
  	respond_to do |format|
    	format.html
    	format.xml { render :xml => result.to_x }
      format.amf { 
        logger.debug "Returning result"
        logger.debug "Returning #{result}"
        render :amf => result 
    	}
    end
=end
    channel_id=params[0]
    site_id=params[1]
    start_ts=params[2] -1
    stop_ts=params[3]+86399
#   logger.error "start_ts equal #{params[2]} stop_ts equal #{params[3]}"

    channel=Channel.find(channel_id)
    freq=channel.channel_freq
    modulation=channel.modulation

    logger.error "freq equal #{freq}"

  yesterday = Time.now.at_beginning_of_day - 86400
  if !(stop_ts < yesterday)
    sql_query1 = "select sumconstellation(image_data) as sumct from sum_constellations where site_id =  ? and dt > ? and dt < ? and freq = ?"
    sql_query2 = "select sumconstellation_lately(image_data) as sumct_lately from constellations where site_id = ? and dt > ? and dt < ? and freq = ?"
    ret1 = SumConstellation.find_by_sql([sql_query1, site_id, start_ts, yesterday, freq])
    ret2 = Constellation.find_by_sql([sql_query2, site_id, yesterday, stop_ts, freq])
    matrix1 = ret1[0][:sumct].unpack("i*")
    matrix2 = ret2[0][:sumct_lately].unpack("i*")
    matrix = []
    (0..65535).each do |index|
      matrix[index] = matrix1[index] + matrix2[index]
    end
  else
    sql_query = "select sumconstellation(image_data) as sumct from sum_constellations where site_id = ? and dt > ? and dt < ? and freq = ?"
    ret = SumConstellation.find_by_sql([sql_query, site_id, start_ts, stop_ts, freq])
    matrix = ret[0][:sumct].unpack("i*")
  end

    result={}
    result[:modulation]=modulation
    result[:matrix]=matrix
    respond_to do |format|
      format.html
      format.xml { render :xml => result.to_x }
      format.amf {
        logger.debug "Returning result"
        logger.debug "Returning #{result}"
        render :amf => result
      }
    end
  end
  
  ##############
  # Get Recent JMeasurements
  #####################
  
  # getRecentMeasurements(siteId:int, measureIds:Array, channelIds:Array)
  def get_recent_measurements()
    site_id=params[0]
    measureList=params[1]
    channelList=params[2]
    data=Measurement.get_recent(site_id, measureList, channelList)
    return_list=[]
    curr_chid=nil
    vals=[]
    meas=[]
    min_limits=[]
    max_limits=[]
    logger.debug "Looping through Data #{data.length} count"
    if data.length == 0
      meas_result={}
      meas_result[:measurements]=return_list
    else
      data.each { |rec|
        if curr_chid != rec.channel_id #If the channel channges.
          if (!curr_chid.nil?) #If this is not the first channel.
            #Store off the current channel
            res = {}
            res[:val]=vals
            res[:measure_id]=meas
            res[:channel_id]=curr_chid
            res[:min_limit]=min_limits
            res[:max_limit]=max_limits
            return_list.push(res)
            vals=[]
            meas=[]
            min_limits=[]
            max_limits=[]
          end
        end
        vals.push(rec.value)
        meas.push(rec.measure_id)
        curr_chid=rec.channel_id
        min_limits.push(rec.min_limit)
        max_limits.push(rec.max_limit)
        logger.debug vals.inspect()
        measure_obj=Measure.find(rec.measure_id)
        meas_ident=measure_obj.sf_meas_ident
      }
      #For the last channel
      if !vals.nil?
        res = {}
        res[:val]=vals
        res[:measure_id]=meas
        res[:channel_id]=curr_chid
        res[:min_limit]=min_limits
        res[:max_limit]=max_limits
        return_list.push(res)
      end
      logger.debug return_list.inspect()
      meas_result={}
      meas_result[:measurements]=return_list
      puts meas_result.inspect()
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => meas_result.to_x }
      format.amf { 
        logger.debug "Returning meas_result"
        logger.debug "Returning #{meas_result}"
        render :amf => meas_result 
      }
    end
  end
  
  # getChannels(siteId:int)
  def get_channels(site_id=nil)
    if site_id.nil?
       if params.key?(0) 
         site_id=params[0].to_i
       else
         raise "No site passed to get_datalog_range #{params.inspect()}"
       end
    end
    logger.debug "Get Channels"
    site=Site.find(site_id)
    analyzer_id=site.analyzer.id
    channel_list=Channel.find(:all, :conditions => {:site_id=>site_id})
    channel_result=[]
    channel_list.each{ |chan|
      logger.debug(chan.inspect())
      chinfo={}
      chinfo[:id]=chan.id
      chinfo[:channel_freq]=chan.channel_freq
      chinfo[:channel_name]=chan.channel_name
      chinfo[:channel]=sprintf("%8.4f MHz",chan.channel_freq/1_000_000)
      chinfo[:channel_type]=chan.channel_type
      channel_result.push(chinfo)
    }
    respond_to do |format|
      format.xml { render :xml => channel_result }
      format.amf { 
        render :amf => channel_result 
      }
    end
  end
  
  # getDatalogRange(siteId:int)
  def get_datalog_range(site_id=nil)
    logger.debug "Inside get_datalog_range"
    if site_id.nil?
       if params.key?(0) 
         site_id=params[0].to_i
       else
         raise "No site passed to get_datalog_range #{params.inspect()}"
       end
    end
    datalog_range=Datalog.get_range(site_id)
    logger.debug datalog_range.inspect()
    result=nil
    if (!datalog_range[:min_ts].nil?)
      result={}
      result[:min_ts]=datalog_range[:min_ts]
      result[:max_ts]=datalog_range[:max_ts]
      result[:min_freq]=datalog_range[:min_freq]
      result[:max_freq]=datalog_range[:max_freq]
      logger.debug "returning datalog_range"
    else
      result={}
      result[:min_ts]=Time.now()
      result[:max_ts]=Time.now()
      result[:min_freq]= ConfigParam.get_value(ConfigParam::StartFreq)
      result[:max_freq]= ConfigParam.get_value(ConfigParam::StopFreq) 
      logger.debug "returning empty datalog_range"
      
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => datalog_range.to_x }
      format.amf { 
        logger.debug "Returning datalog_range"
        logger.debug "Returning #{datalog_range}"
        render :amf => result
      }
    end
  end
  
  #####################
  # get_datalog_trace
  # Get the summary data for the traces given the range
  #####################
  
  # getDatalogTrace(transactionId:int, traceLabel:String, siteId:int, startFreq:Number, stopFreq:Number, startTime:Date, stopTime:Date, freqRes:int, tsRes:int, overtimeFlag:Boolean)
  def get_datalog_trace
    transaction_id=params[0]
    trace_label=params[1]
    site_id=params[2]
    start_freq=params[3]
    stop_freq=params[4]
    start_ts=params[5] 
    stop_ts=params[6] 
    freq_res=params[7] 
    ts_res=params[8]
    datalog_range=Datalog.get_range(site_id)
    logger.debug datalog_range.inspect()
    logger.info("START TS : #{start_ts}")
    logger.info("STOP TS : #{stop_ts}")
    ds={}
	  
	###TODO
	
	  
	  
    if (datalog_range.nil?) || datalog_range[:max_ts].nil? || datalog_range[:max_ts].nil?
      ds["min_freq"]=datalog_range[:min_freq]
      ds["max_freq"]=datalog_range[:max_freq]
      ds["min_ts"]=nil
      ds["max_ts"]=nil
      ds["transaction_id"]=transaction_id
      ds["trace_label"]=trace_label
    else
      one_hour_ago=datalog_range[:max_ts]-3600
      logger.debug "One hour ago #{one_hour_ago.to_s} Most Recent #{datalog_range[:max_ts]}"
      overtime_flag=params.key?(9) ? params[9] : false
      site=Site.find(site_id)
      profile=nil
      anl=nil
      if site.nil?
        raise "Failed to find Site."
      else
        logger.debug "Getting Profile for site #{site.id}"
        profile=site.get_profile()
      end
      datalog=Datalog.summarize_datalogs(
        {
          :site_id=>site_id, 
          :start_ts=>start_ts,
          :stop_ts=>stop_ts,
          :start_freq=>start_freq,
          :stop_freq=>stop_freq
        },
        overtime_flag)
        recent_datalog=Datalog.summarize_datalogs(
        {
          :site_id=>site_id, 
          :start_ts=>one_hour_ago,
          :stop_ts=>datalog_range[:max_ts],
          :start_freq=>start_freq,
          :stop_freq=>stop_freq
        },
        overtime_flag)
        ds["recent"]=recent_datalog[:max]
      datalog_list=[]
      ds["trace_label"]=trace_label
      ds["avg"]=datalog[:avg]
      ds["min"]=datalog[:min]
      ds["max"]=datalog[:max]
      ds["total"]=datalog[:total]
      ds["noise_floor"]=datalog[:noise_floor] if overtime_flag
      logger.debug "Datalog length #{ds["max"].length}"
      if ((!profile.nil?) && (!overtime_flag))
        logger.debug "Got Profile #{profile.name()}, #{start_freq}, #{stop_freq}"
        ds["profile_id"]=profile.id
        ds["profile_name"]=profile.name
        ds["profile_ref"]=profile.trace(start_freq, stop_freq)
        #ds["profile_ref"]=profile.trace()
        ds["profile_major"]=profile.major_offset
        ds["profile_minor"]=profile.minor_offset
        ds["profile_loss"]=profile.loss_offset
        ds["profile_loss_flag"]=profile.link_loss
      else
        logger.debug "Did not get Profile #{profile.inspect()}"
      end
      logger.debug datalog.inspect()
      logger.debug "Finished Total"
      if datalog.key?(:freq)
        ds["freq"]=datalog[:freq]
      else
        ds["freq"]=[]
      end
      if datalog.key?(:time)
        ds["time"]=datalog[:time]
      else
        ds["time"]=[]
      end
      ds["min_freq"]=datalog[:min_freq]
      ds["max_freq"]=datalog[:max_freq]
      ds["min_ts"]=datalog[:min_ts]
      ds["max_ts"]=datalog[:max_ts]
      ds["transaction_id"]=transaction_id
      
      
	  
      logger.debug ds["freq"].inspect()
      logger.debug "Finished Transaction.  Now building XML"
    end
    respond_to do |format|
      format.amf { 
        render :amf => ds
      }
    end
  end
  
  # getProfileList()
  def get_profile_list
    profile_list=Profile.find_active_profiles.sort {|a,b| a.name<=>b.name}
    list=[]
    profile_list.each { |prof_rec|
      pf={}
      pf["name"]=prof_rec.name
      pf["id"]=prof_rec.id
      list.push(pf)
    }
    respond_to do |format|
      format.amf { 
        render :amf => list
      }
    end
  end
  
  # getProfile(name:String)
  def get_profile
    name=params[0]
    profile_rec=Profile.find_by_name(name, :conditions => "status is NULL")
		profile_obj={}
    unless profile_rec.nil?
			idx=0
			profile=[]
			start_freq=ConfigParam.get_value(ConfigParam::StartFreq)
			freq_range=ConfigParam.get_value(ConfigParam::StopFreq) -
			  ConfigParam.get_value(ConfigParam::StartFreq)
			delta=freq_range/Profile::SAMPLE_COUNT 
			profile_rec.trace.each { |point|
			  point_obj={}
			  point_obj["val"]=point
			  point_obj["freq"]=delta*idx+start_freq
			  profile.push(point_obj)
			  idx+=1
			}
			profile_obj["major_offset"]=profile_rec.major_offset
			profile_obj["minor_offset"]=profile_rec.minor_offset
			profile_obj["loss_offset"]=profile_rec.loss_offset
			profile_obj["link_loss"]=profile_rec.link_loss ? 1 : 0
			profile_obj["profile"]=profile
    end
		respond_to do |format|
      format.amf { 
        render :amf => profile_obj
      }
    end
  end
  
  # setProfile(name:String, traceVals:Array, traceFreqs:Array, major:Number, minor:Number, loss:Number, hasLinkLoss:Boolean)
  def set_profile()
    name=params[0]
    trace_vals=params[1] 
    trace_freqs=params[2] 
    major=params[3] 
    minor=params[4]
    loss=params[5]
    loss_flag=params[6]
    profile=Profile.find(:first,:conditions=>["name=?",name]);
    if !profile.nil?
      logger.debug "Saving #{profile.id}"
    else
      logger.debug "Saving new profile"
    end

    #If record does not exist then create a new one.
    if (profile.nil?) 
      profile=Profile.new()
      profile.name=name
      logger.debug "Logging Profile #{profile.name}"
    end
    trace=[]
    result={}
    result[:saved]=false
    logger.debug("#{trace_vals.length.inspect()} ------------ #{trace_freqs.length.inspect()}")
    if (trace_vals.length.to_i ==trace_freqs.length.to_i)
      profile.trace=Profile.build_trace(trace_vals,trace_freqs)
      profile.major_offset=major
      profile.minor_offset=minor
      profile.loss_offset=loss
      profile.link_loss=loss_flag
      result[:saved]= profile.save 
    else
      result[:error]="Freq. Count and Value count are not equal."
    end
    logger.debug result.inspect()
    if !result[:saved] 
      result[:error]=profile.errors.full_messages.join("---")
    end
    logger.debug result.inspect()
    respond_to do |format|
      format.amf { 
        render :amf => result
      }
    end
  end
  
  # internal function
  def _gen_filter(list, attr_name)
    filter_components=list.collect { |item|
      "(#{attr_name}=#{item})"
    }
    return "("+filter_components.join(" or ")+")"
  end
  
######
# get_channel_info
# Get the details for each channel
###################

	# getChannelInfo(channelId:int, siteId:int)
  def get_channel_info()
    channel_id=params[0]
    site_id=params[1]
    channel=Channel.find(channel_id)
    chinfo=nil
    site=Site.find(site_id)
    if channel.nil? #Return nil if channel not found.
      logger.error "No Channel Object found for channel id #{channel_id}."
    elsif site.nil? #Return nil if site not found.
      logger.error "No site found for site id #{site_id}."
    else

        meas_list=Measurement.find_by_sql(["select distinct measure_id as meas_id from measurements left join measures on measurements.measure_id=measures.id where site_id=? and channel_id=? and graph_flag=1",site_id, channel_id])

   
        chinfo={}
        chinfo[:channel_id]=channel_id
        chinfo[:channel_nbr]=channel.channel
        chinfo[:channel_name]=channel.channel_name
        chinfo[:modulation]=channel.modulation
        chinfo[:channel_freq]=channel.channel_freq.to_f
        chinfo[:meas_list]=meas_list.collect { |meas| meas.meas_id}
    end
    respond_to do |format|
      format.amf { 
        render :amf => chinfo
      }
    end
  end
  
  # saveSnapshot(userId:String, siteId:int, imageBuffer:Array, session:String)
  def save_snapshot()
    result={}
	result[:session]=[]
	dt=Time.now()
	#logger.debug("Hello Jerry World #{snap_data[:image_buffer].inspect()}\n")#[:image_buffer].inspect()
	site_id=params[1]
	s_session=params[3]
	trace=params[2]
	user_ip=params[0]
	an=Site.find(site_id.to_i).analyzer
	n_f=Datalog.cal_noise_floor(trace,an.id)
    f_session= (s_session!="" && Snapshot.exists?(:session=>s_session)) ? s_session : "#{dt.to_i}_#{site_id}_#{user_ip}"
	snap=Snapshot.new()	 
	snap.update_attributes(:image=>trace,:source=>'Realview',:noise_floor=>n_f,:create_dt=>dt,:site_id=>site_id,:session=>f_session,:description=>"livetrace")
    result[:session]=f_session   
    respond_to do |format|
			format.amf { 
		    render :amf => result
		 	}
	  end
  end

	# getAnalyzerStatus(analyzerId:int)
  def get_analyzer_status
  #  DISCONNECTED=10
  #  CONNECTED=11
  #  INGRESS=12
  #  DOWNSTREAM=13
  #  PROCESSING=14
  #  SWITCHING=15
    an_id=params[0]
    result=99
    unless an_id.nil?
      result=Analyzer.find(an_id).get_status
		end
    respond_to do |format|
			format.amf { 
	    render :amf => result
	 		}
		end
  end	
	
	# getMajorMinor(siteId:int)
  def get_major_minor
  	site_id=params[0]
    site=Site.find(site_id)
  	start_freq=site.analyzer.start_freq
    stop_freq=site.analyzer.stop_freq
  	if site.nil?
      raise "Failed to find site."
		end
		
		ds={}
    logger.debug "Getting Profile for site #{site.id}"
    profile=site.get_profile()
		if profile.nil?
			logger.debug "Failed to get profile."
		else
		ds["ref"]=profile.trace(start_freq, stop_freq)
	    ds["major"]=profile.major_offset
	    ds["minor"]=profile.minor_offset
		end
		
		respond_to do |format|
		format.amf { 
			render :amf => ds
		}
		end
	end	
  
  # getMeasValues(channelId:int, measureId:int, siteId:int, startDate:Date, stopDate:Date)
  def get_meas_values()
    channel_id=params[0]
    meas_id=params[1]
    site_id=params[2]
    start_dt=params[3]
    stop_dt=params[4]+86399
    result={}
    result[:meas_values]=[]
    result[:meas_max_values]=[]
    result[:meas_min_values]=[]
    result[:min_limits]=[]
    result[:max_limits]=[]
    result[:dates]=[]
    meas=Measure.find(meas_id)
    if !meas.nil?
      sql_query=" channel_id=? and measure_id=? and site_id=? and dt between ? and ? "
      new_start_dt=Measurement.minimum("dt",:conditions =>[sql_query, channel_id,meas_id, site_id, start_dt.strftime('%F %T'),(stop_dt+1).strftime('%F %T')])
      new_stop_dt=Measurement.maximum("dt",:conditions  =>[sql_query, channel_id,meas_id, site_id, start_dt.strftime('%F %T'),(stop_dt+1).strftime('%F %T')])
      point_cnt=Measurement.count(:conditions =>          [sql_query, channel_id,meas_id, site_id, start_dt.strftime('%F %T'),(stop_dt+1).strftime('%F %T')])
       logger.debug("SUMMARY #{new_start_dt}, #{new_stop_dt}, #{point_cnt}")

      start_tm=new_start_dt.strftime(fmt="%s")
      stop_tm=new_stop_dt.strftime(fmt="%s")
      secs_diff=stop_tm.to_i-start_tm.to_i
      if (point_cnt <=201) #Dont't Start averaging data for 3 days. three days.
         sec_divisor=1
      else
         sec_divisor=(secs_diff/201).ceil
         logger.debug("SECS DIFF #{secs_diff}=#{stop_tm}-#{start_tm}")
         logger.debug("Divisor #{sec_divisor}=#{secs_diff}/201)")
      end
    #//The purpose of this query is to pull and summarize the measurement data.
    #// It tries to get 201 samples.  If there are more than 201 samples on 
    #// the specified data range it will group the samples 
    #// together and take the max, min
    #// and average to build the charts.
    #// The group by function is based on the Time Range/201 So we can get 201 equally distributed points on the graph.
    #// This data may have also been summarized by a summarize_data cron job.
      sql_query="select min(dt) as dt ,Round(avg(value),dec_places) as value,Round(min(min_value),dec_places)as min_value,Round(max(max_value),dec_places)as max_value,min(min_limit) as min_limit, max(max_limit) as max_limit from measurements left join measures on measure_id=measures.id where channel_id=? and measure_id=? and site_id=? and dt between ? and ? group by floor(unix_timestamp(dt)/?)";
      values=Measurement.find_by_sql(
        [sql_query, channel_id, meas_id, site_id,start_dt.strftime('%F %T'),(stop_dt+1).strftime('%F %T'), sec_divisor])
      values.each { |rec|
        result[:meas_values].push(rec.value)
        result[:meas_max_values].push(rec.max_value)
        result[:meas_min_values].push(rec.min_value)
        result[:dates].push(rec.dt)
        result[:min_limits].push(rec.min_limit)
        result[:max_limits].push(rec.max_limit)
      }
      puts logger.debug "RESULT LENGTH #{result.length}"
      meas=Measure.find(meas_id)
      if meas.nil?
        result[:measure_name]="UNKNOWN MEASURE"
      else
        result[:measure_name]=meas.measure_label
      end
      result[:measure_id]=meas_id
      result[:channel_id]=channel_id
      result[:site_id]=site_id
      result[:exp_flag]=meas.exp_flag 
      result[:sanity_max]=meas.sanity_max
      result[:sanity_min]=meas.sanity_min
      result[:uom]=meas.uom
    end
    respond_to do |format|
      format.amf { 
        render :amf => result
      }
    end
  end
end
