class MonitorUtils

def MonitorUtils::sf_to_avantron_annex(sf_annex)
  avantron_annex=0
  annex_arr=[1,2,3,0]
  if !sf_annex.nil?
    if (sf_annex.to_i <= 3)
      avantron_annex=annex_arr[sf_annex]
    else
      avantron_annex=1
    end
  else
    avantron_annex=1 
  end
  return avantron_annex
end

def MonitorUtils::sf_to_avantron_QAM_modulation(sf_modulation)
  if sf_modulation.nil?
    return 5 #QAM 256
  elsif sf_modulation.to_i == 3
    return 5 #QAM 256
  else
    return 3 #QAM 64
  end
end
end
