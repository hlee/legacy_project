class SystemLog < ActiveRecord::Base
  belongs_to :analyzer
  #Levels
  MESSAGE=8
  WARNING=16
  PROGRESS=32#When analyzer in processing mode we use these message types to report progress.
  ERROR=128
  EXCEPTION=192
  RECONNECT=256
  def SystemLog.log(short_descr=nil, descr=nil,level=128,analyzer_id=nil,ts=nil)
    if (short_descr.nil?)
      return nil
    end
    if(descr.nil?)
      descr=short_descr
    end
    if (ts.nil?)
      ts=Time.now
    end
    if (!analyzer_id.nil?)
      #Verify analyzer
      anl=Analyzer.find(analyzer_id)
      if (anl.nil?)
        return nil
      end
    end
    if level==PROGRESS
      if anl.progress!=short_descr
        anl.progress=short_descr
        anl.save
      end
    end
    if level==EXCEPTION
      if anl.exception_msg!=short_descr
        anl.exception_msg=short_descr
        anl.save
      end
    end
    log_rec=SystemLog.create({:short_descr=>short_descr, :descr=>descr, 
      :level=>level, :analyzer_id=>analyzer_id,:ts=>ts})
    return log_rec.id
  end
  def msg_type
    if (level == MESSAGE)
      return "INFO"
    elsif (level == WARNING)
      return "WARNING"
    elsif (level == ERROR)
      return "ERROR"
    else
      return level.to_s
    end
  end
end
