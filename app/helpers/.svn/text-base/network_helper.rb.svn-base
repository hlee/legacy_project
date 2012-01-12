module NetworkHelper
  def regid2name(id)
    region=Region.find_by_id(id)
    return region[:name]
  end
  
  def show_auto_status(id)
  anl=Analyzer.find(id)
    if is_auto(id)
	  return 'AUTO_CONNECT/'+Analyzer.status_to_str(anl.get_status(),id).slice(/^[^ {]*/)
	else
	  return Analyzer.status_to_str(anl.get_status(),id).slice(/^[^ {]*/)
	end
  end
  
  def is_auto(id)
    anl=Analyzer.find(id)
	if anl.att_count == 999
	  return false
	end
	if anl.att_count < 9 and anl.auto_mode != 3 and anl.att_count >= 0
	  return true
	else
	  return false
	end
  end
end
