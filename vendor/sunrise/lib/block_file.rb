
module BlockFile
class BlockFileError < StandardError
end



class BlockFileParser
   attr_accessor  :file_formats, :magic_nbr, :revision, :version, :block_list
   CFG_MAGIC=0x1600
   def inspecter()
      result="MAGIC NBR:#{@magic_nbr}," <<
      "REVISION:#{@revision}, VERSION:#{@version}"
      @block_list.each { |block|
         result << block.inspect() << "\n-----------------------\n"
      }
      return result
   end
   def initialize()
      @block_list=[]
      @file_formats={
         0x4040=>{
            :format_name=>'Data Logging Format',
            :version_list=>[1],
            :revision=>false,
            :blocks=> {
               1 => {
                  :length=>74,
                  :format => {
                     :template=>'Ca41'+'LLLLL'+'LLL',
                     :keys=>[:test_plan_type,:test_plan_name,
                        :test_plan_number,:test_plan_ver,:cpcrc32, :plan_length,:serial_nbr,
                        :start_time,:stop_time,:nbr_of_records]
                  }
               },
               2 => {
                  :length=>18,
                  :format => {
                     :template=>'LLLLS',
                     :keys=>[:time_of_meas,:sig_src_nbr,:sig_src_ver,:measure_count,:test_count]
                  }
               },
               3 => {
                  :length=>6,
                  :format => {
                     :template=>'SL',
                     :keys=>[:test_number,:measure]
                  }
               },
               4 => {
                  :length=>1002,
                  :format => {
                     :template=>'Sa1000',
                     :keys=>[:test_number,:trace],
                     :post_process=>  {
                        :trace => lambda { |data_str|
                           return data_str.unpack("S500")
                        }
                     }
                  }
               }
            }
         },
         0x1600=> {
            :format_name=>'BinaryHardwareConfigSetup', #itp
            :version_list=>[2],
            :revision=>false,
            :blocks=>{
               1=> {
                  :length => 128,
                  :format => {
                     :template=>'La40SSa40a40',
                     :keys=>[:unique_id,:name,:rtpt_count, :mx_count, :location, :region]
                  }
               },
               2=> {
                  :length => 142,
                  :format => {
                     :template=>'La40Sa40a40'+'CLC'+'LCCL',
                     :keys=>[:unique_id,:name,:port_count, :location,:region,
                        :switch_type, :hw_mux_id, :parent_pos_mux, 
                        :parent_mux_id, :switch_port, :protocol_nbr, :baud_rate]
                  }
               },
               3=> {
                  :length => 126,
                  :format => {
                     :template=>'La40Sa40a40',
                     :keys=>[:unique_id,:name,:port_nbr, :location,:region]
                  }
               }
            }
         },
         0x2829 => {
            :format_name=>'Binary Ingress Setup', #itp
            :version_list=>[3],
            :revision=>false,
            :blocks=>{
               1 => {
                  :length=> 2,
                  :format => {
                     :template => 'S',
                     :keys=>[:signal_source_count]
                  }
               },
               2 => {
                  :length=> 10,
                  :format => {
                     :template => 'LLS',
                     :keys=>[:number, :version, :port]
                  }
               },
               4 => {
                  :length=> 2,
                  :format => {
                     :template => 'S',
                     :keys=>[:test_plan_count]
                  }
               },
               5 => {
                  :length=> 68,
                  :format => {
                     :template => 'LLL'+'a41CS'+'SLS'+'SS',
                     :keys=>[:number,:version,:system_ser,
                       :name,:type,:stat_delay,
                       :data_log_delay,:attenuator,:scan_on_peak_hold,
                       :dwell_time, :step_count]
                  }
               },
               6 => {
                  :length => 19,
                  :format => {
                     :template => 'LLLL'+'CCC',
                     :keys => [:sig_src_nbr, :sig_src_ver, :prof_nbr, :prof_ver,
                        :stat_enabled, :data_logging, :enabled]
                  }
               },
               7 => {
                  :length=> 2,
                  :format => {
                     :template => 'S',
                     :keys=>[:profile_count]
                  }
               },
               8 => {
                  :length=> 52,
                  :format => {
                     :template => 'LLa41CS',
                     :keys=>[:number, :version, :name, :type, :test_count]
                  }
               },
               9 => {
                  :length=> 1046,
                  :format => {
                     :template => 'SCa1000CDDSDDSSSS',
                     :keys=>[:number,:active,:ref_trace,:if_offset,#SCa1000C / 2,1,1000,1
                      :center_freq,:span,:sweep_time,:res_bw,:video_bw,#DDSDD/8,8,2,8,8
                      :vert_scale,:avg_type,:trigger,:thresh_count#SSSS/2,2,2,2
                      ]
                  }
               },
               10 => {
                  :length=> 3,
                  :format => {
                     :template => 'Cs',
                     :keys=>[:compare_type, :value]
                  }
               }
               
            }
         },
         0x2169 => {
            :format_name=>'Binary Channel Plan',#acp
            :version_list=>[3],
            :revision=>true,
            :blocks=>{
               1 => {
                  :length=> 23,
                  :format => {
                     :template => 'Sa21',
                     :keys=>[:channel_plan_count, :default_plan_name]
                  }
               },
               2 => {
                  :length=> 159,
                  :format => {
                     :template => 'a21a101a31a4S',
                     :keys=>[:plan_name, :descr, :author, 
                        :country_code, :channel_count]
                  }
               },
               3 => {
                  :length=> 29,
                  :format => {
                     :template => 'a5a21CCC',
                     :keys=>[:channel_nbr, :channel_name, :channel_type,
                        :test,:forward_reverse]
                  }
               },
               4 => {
                  :length=> 23,
                  :format => {
                     :template => 'LLS'+'LCLL',
                     :keys=>[:center_freq, :channel_width, :modulation, 
                     :symbol_rate, :burst,:tdmalen,:tdmarepeatrate ]
                  }
               },
               5 => {
                  :length=> 16,
                  :format => {
                     :template => 'LLS'+'Lcc',
                     :keys=>[:center_freq, :channel_width, :mod,
                        :symbol_rate, :polarity, :j83annex]
                  }
               },
               6 => {
                  :length=> 121,
                  :format => {
                     :template => 'LLLL'+'cLLS'+'ccL'+'ScL'+'LL' +
                        'Scl'+'Sc'+ 'cl'+ 'cl'+ 'cl'+ 'cl'+
                        'Scc'+'LLLLL'+'Scc'+'Scc'+'Scc'+'Scc' +
                        'ccc' ,
                     :keys=>[
                       :videoFreq, :audio1Freq, :audio2Freq, :audio2Bw,#LLLL
                       :audio2Type, :chanwLow,:chanwUp,:mod,#cLLS
                       :scramble,:hum,:humFreq,#ccL
                       :ccnGateLine, :ccnGateField, :ccnFreqOffLow,#ScL
                       :ccnFreqOffUp,:videoNoiseBw,#LL
                       :ctbGateLine, :ctbGateField, :ctbFreqOff,#Scl
                       :csoGateLine,:csoGateField,#Sc
                       :csoFreqOffLowTag1, :csoFreqOffLowValue1,#cs
                       :csoFreqOffLowTag2, :csoFreqOffLowValue2,#cs
                       :csoFreqOffUpTag1, :csoFreqOffUpValue1,#cs
                       :csoFreqOffUpTag2, :csoFreqOffUpValue2,#cs
                       :icrLine,:icrField,:icrSigType,#Scc
                       :icrFreq1, :icrFreq2, :icrFreq3, :icrFreq4, :icrFreq5,#LLLLL
                       :domLine,:domField,:domSigType,#Scc
                       :vidDiffGainPhLine, :vidDiffGainPhField, :vidDiffGainPhSigType,#Scc
                       :vidYCLine,:vidYCField,:vidYCSigType,#Scc
                       :vidSNLine,:vidSNField,:vidSNSigType,#Scc
                       :humTest, :ccnGateTest,:domTest#ccc
                       
                       ]
                  }
               }
               
            }
         }
      }
      
   end
   def save(filename)
      f=File.open(filename,'wb')
      file_details=@file_formats[@magic_nbr]
      f.write([@magic_nbr,@version].pack('SS'))
      if file_details[:revision]
         f.write(@revision.pack('S'))
      end
      @block_list.each { |block|
         block_type=block[:_block_type]
         block_def=file_details[:blocks][block_type]
         block_size=file_details[:blocks][block_type][:length]
         f.write([block_type, block_size].pack('SS'))
         #puts block_def.inspect()
         param_values=block_def[:format][:keys].collect { |key| block[key]}
         puts param_values.inspect()
         puts block_def[:format][:template].inspect()
         record=param_values.pack(block_def[:format][:template])
         if block_size != record.length
            raise BlockFileError.new(
               "Did not pack properly #{block_type} expected: #{block_size} actual: #{record.length}")
         end
         f.write(record)
      }
      f.write([65535,0].pack('SS'))
      f.close
   end
   def load(filename)
      f=File.open(filename,'rb')
      file_details={}
      @magic_nbr,@version=f.read(4).unpack('SS') #reading the magic number & ver.
      file_details=@file_formats[@magic_nbr]
      if file_details[:revision]
         @revision=f.read(2).unpack('S')
      end
      if (@file_formats.key?(@magic_nbr))
         puts "Loading for #{@file_formats[@magic_nbr][:format_name]}"
      else
         raise BlockFileError.new("Do not recognize Magic Number #{@magic_nbr}")
      end
      version_found=false
      file_details[:version_list].each { |version_item|
         if (@version==version_item)
            version_found=true
         end
      }
      block_type=0
      while (!f.eof) && (block_type != 65535)
         block_type, block_size=f.read(4).unpack('SS')
         if block_type != 65535
            block_def=file_details[:blocks][block_type]
            if (block_def.nil?)
               raise BlockFileError.new("Block Type #{block_type} for magic # #{@magic_nbr} not recognized. FYI it had a block size of #{block_size}")
            end
            if (block_type != 65535)
               if (block_def.key?(:length)) && (block_size != block_def[:length])
                  raise BlockFileError.new("Block Length for type #{block_type}. (#{block_def[:length]} <> #{block_size}) @ #{f.pos}")
               end
               data_block=f.read(block_size)
               data=data_block.unpack(block_def[:format][:template])
               if (data.length != block_def[:format][:keys].length)
                  raise BlockFileError.new(
                     "Format length does not agree with keys length. (#{data.length} <> #{block_def[:format][:keys].length}) for blocktype #{block_type}/#{@magic_nbr}")
               end
               datarec={:_block_type => block_type}
               data.each_index { |index|
                  tmp_data=data[index]
                  field=block_def[:format][:keys][index]
                  if block_def[:format].key?(:post_process) && block_def[:format][:post_process].key?(field)
                     post_proc=block_def[:format][:post_process][field]
                     datarec[field]=post_proc.call(tmp_data)
                  else
                     datarec[field]=tmp_data
                  end
               }
               datarec[:block_type]=block_type
               @block_list.push(datarec)
               #puts datarec.inspect()
            end
         end
      end
      if (f.eof) && (block_type != 65535)
         raise BlockFileError.new("EOF unexpected")
      end
      return @block_list

   end
end

end
