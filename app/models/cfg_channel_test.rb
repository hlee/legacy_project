class CfgChannelTest < ActiveRecord::Base
   belongs_to :cfg_channel
   has_many :cfg_channel_test_dtl

   ########################################
   # Depending on Measurement being made this
   # function returns what modes are necessary.
   # ######################################
   def test_requires(mode)
      qam_flag= mer_flag || preber_flag || postber_flag || enm_flag||evm_flag
      if (mode == :qam)
         return qam_flag 
      elsif (mode == :dcp)
         return qam_flag || dcp_flag
      elsif (mode == :analog)
         return video_lvl_flag || varatio_flag || mvf_flag || maf_flag
      else
         return false
      end
   end
   
   ########################################
   # Test limits based on data sent
   ########################################
   def do_test(meas_ident)
     if ((meas_ident == 1123) || (meas_ident == 1117))
       return preber_flag
     elsif ((meas_ident == 1124) || (meas_ident == 1118))
       return postber_flag
     elsif ((meas_ident == 1125) || (meas_ident == 1119))
       return mer_flag
     elsif ((meas_ident == 1010) )
       return video_lvl_flag
     elsif ((meas_ident == 1011) )
       return varatio_flag
     elsif ((meas_ident == 3003) )
       return enm_flag
     elsif ((meas_ident == 3002) )
       return evm_flag
     elsif ((meas_ident == 3001) )
       return dcp_flag
	 elsif (meas_ident == 3101)
	   return mvf_flag
	 elsif (meas_ident == 3102)
	   return maf_flag
     end
   end

   ########################################
   # Based on the measure ident this function pulls the current limits from the
   # CfgChannelTest
   # ######################################
   def get_limits(meas_ident)
      meas=Measure.find(:first,:conditions=>{:sf_meas_ident =>meas_ident})
      if ((meas_ident==1123) || (meas_ident==1117))
         return [nil,nil,preber_minor,preber_major]
      
      elsif ((meas_ident==1124) || (meas_ident==1118))
         return [nil,nil,postber_minor,postber_major]
      elsif ((meas_ident==1125) || (meas_ident==1119))
         if (mer_nominal.nil?)
            return [nil,nil,nil,nil]
         else
            return [mer_nominal-mer_major,mer_nominal - mer_minor,nil,nil]
         end
      elsif (meas_ident==3101)
         if (mvf_nominal.nil?)
            return [nil,nil,nil,nil]
         else
           return [
			   mvf_nominal-(mvf_major || 0),
			   mvf_nominal-(mvf_minor || 0),
			   mvf_nominal+(mvf_minor || 0),
			   mvf_nominal+(mvf_major || 0)]
         end
      elsif (meas_ident==3102)
         if (maf_nominal.nil?)
            return [nil,nil,nil,nil]
         else
           return [
			   maf_nominal-(maf_major || 0),
			   maf_nominal-(maf_minor || 0),
			   maf_nominal+(maf_minor || 0),
			   maf_nominal+(maf_major || 0)]
         end
      elsif (meas_ident==1010)
         if (video_lvl_nominal.nil?)
            return [nil,nil,nil,nil]
         else
           return [
			   video_lvl_nominal-(video_lvl_major || 0),
			   video_lvl_nominal-(video_lvl_minor || 0),
			   video_lvl_nominal+(video_lvl_minor || 0),
			   video_lvl_nominal+(video_lvl_major || 0)]
         end
      elsif (meas_ident==1011)
         if (varatio_nominal.nil?)
           return [nil,nil,nil,nil]
         else
           return [
			   varatio_nominal-(varatio_major || 0),
			   varatio_nominal-(varatio_minor || 0),
			   varatio_nominal+(varatio_minor || 0),
			   varatio_nominal+(varatio_major || 0)]
         end
      elsif ((meas_ident==3003))
         if (enm_nominal.nil?)
           return [nil,nil,nil,nil]
         else
           return [enm_nominal - (enm_major || 0) ,enm_nominal - (enm_minor || 0),nil,nil]
         end
		
      elsif ((meas_ident==3002))
          if (evm_nominal.nil?)
            return [nil,nil,nil,nil]
          else
            return [nil,nil,evm_nominal + (evm_minor || 0),evm_nominal + (evm_major || 0) ]
          end
      elsif (meas_ident==3001)
         if (dcp_nominal.nil?)
           return [nil,nil,nil,nil]
         else
           return [
			   dcp_nominal-(dcp_major || 0),
			   dcp_nominal-(dcp_minor || 0),
			   dcp_nominal+(dcp_minor || 0),
			   dcp_nominal+(dcp_major || 0)]
         end
     end	
   end
end
