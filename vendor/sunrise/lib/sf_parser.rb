
require 'yaml'
require 'iconv'
require 'active_record'
require "#{RAILS_ROOT}/app/models/sf_system_file"
module SF_Parser

class SFParserError < StandardError
end

class SFParser
#system_file=ARGV[0]
#puts ("System File:" + system_file)

   

#if !FileTest.exist?(system_file)
#   puts ("System File "+system_file+" does not exist!")
#   exit
#end
#if !FileTest.readable?(system_file)
#   puts ("System File "+system_file+" is not readable!")
#   exit
#end
#
#puts("Scanning |"+system_file + "|\n")
#
def SFParser::unicode_string(array_of_int)
   result_str =''
   array_of_int.each { |x|
      if x.nil?()
         result_str='NIL'
         return result_str
      end
      if (x == 0)
         result_str+=''
      else
         result_str +=x.chr
      end

   }
   return result_str
end

def SFParser::dumphash(hsh)
   content=''
   hsh.each do |key, value|
      if key.nil?()==true
         content << "Skipping nil key"
      elsif value.nil?
         content << "Skipping nil for " << key.to_s << "<br>"
      elsif value.class == 'string'
         content << key.to_s << " => " << value << "<br>"
      else
         content << key.to_s << " => " <<value.to_s << "<br>"
      end
   end
   return content
end

def SFParser::parse_type0(block)
   unpacked_block=block.unpack('s21sss')
   i=0
   data={}
   data[:num_of_locations]=unpacked_block[23]
   data[:num_of_simple_channels]=unpacked_block[22]
   data[:setup_count]=unpacked_block[21]
   data[:system_file_name] =unicode_string(unpacked_block[0..20])
   #dumphash(data)
   return data
   end

def SFParser::parse_type1(block)
   unpacked_block=block.unpack('s21s101s31ss36')
   i=0
   data={}
   data[:name]=unicode_string(unpacked_block[0..20])
   data[:descr]=unicode_string(unpacked_block[21..121])
   data[:author]=unicode_string(unpacked_block[122..152])
   data[:num_channels]=unpacked_block[153]
   data[:guid]=unicode_string(unpacked_block[154..189])
   #dumphash(data)
   return data
end
def SFParser::parse_type2(block)
   unpacked_block=block.unpack('s5s21CCCCCC')
   i=0
   data={}
   data[:number]=unicode_string(unpacked_block[0..4])
   data[:name]=unicode_string(unpacked_block[5..25])
   data[:type]=unpacked_block[26]
   data[:direction]=unpacked_block[27]
   data[:usefullscan]=unpacked_block[28]
   data[:useminiscan]=unpacked_block[29]
   data[:active]=unpacked_block[30]
   data[:unitType]=unpacked_block[31]
   #dumphash(data)
   return data
end
def SFParser::parse_type3(block)
   unpacked_block=block.unpack('LLSLCCCCS')
   data={}
   fields=['centerfreq','bandwidth','modulation','symbolrate','polarity','j83annex','usefec','equalizer','docsis_ranging']
   unpacked_block.each_index { |index|
      data[fields[index]]=unpacked_block[index]
   
   }
   #dumphash(data)
   return data
end
def SFParser::parse_type4(block)
   unpacked_block=block.unpack('LSSLSLSLSCCCLCLCLCLSCLSCLLSCCLLLLLCCSCC')
   data={}
   fields=['videofreq','modulation','videodwelltime','va1sep',\
            'audio1dwelltime','va2sep','audio2dwelltime','bandwidth',\
            'csogatedline','csogatedfield','csoofffsetflag','csofreqlow1tag',\
            'csofreqlow1value','csofreqlow2tag','csofreqlow2value', \
            'csofrequp1tag','csofrequp1value', \
            'csofrequp2tag','csofrequp2value', \
            'ctbgated.line','ctbgatedfield','ctbfreqoffset', \
            'ccngatedline', 'ccngatedfield','ccnfreqoffsetlow','ccnfreqoffsetup' \
            'icrline','icrfield','icrsigtype',\
            'icrfreq1','icrfreq2','icrfreq3','icrfreq4','icrfreq5',\
            'hum','humfreq','domline','domfield','domsignaltype']

   unpacked_block.each_index { |index|
      data[fields[index]]=unpacked_block[index]
   
   }
   #dumphash(data)
   return data
end
def SFParser::parse_type5(block)
   unpacked_block=block.unpack('Ss21')
   i=0
   data={}
   data['id']=unpacked_block[0]
   data['name']=unicode_string(unpacked_block[1..21])
   #dumphash(data)
   return data
end
def SFParser::parse_type6(block)
   unpacked_block=block.unpack('s5SC')
   i=0
   data={}
   data['channel']=unicode_string(unpacked_block[0..4])
   data['testtype']= unpacked_block[5]
   data['enable']=unpacked_block[6]
   #dumphash(data)
   return data
end
def SFParser::parse_type7(block)
   unpacked_block=block.unpack('SCCfffC')
   data={}
   fields=['testtype','enable','datatype','minvalue','maxvalue','tolerance','units']

   unpacked_block.each_index { |index|
      data[fields[index]]=unpacked_block[index]
   
   }
   #dumphash(data)
   return data
end
def SFParser::parse_type8(block)
   unpacked_block=block.unpack('Cs5s21LSCL')
   i=0
   data={}
   data['centerfreq']=unpacked_block[28]
   data['pilot']=unpacked_block[31]
   #dumphash(data)
   return data
end
def SFParser::parse_type9(block)
   unpacked_block=block.unpack('SCs30')
   i=0
   data={}
   data['setuptype']= unpacked_block[0]
   data['datatype']=unpacked_block[1]
   data['value']=unicode_string(unpacked_block[2..31])
   #dumphash(data)
   return data
end




def SFParser::system_file_load(filename, display_name=nil)
   current_state={}
   output = 'XXX'
   output << filename 
   output << "|<br>"
   f=File.open(filename,'rb')
   #Let's read the magic number and version.
   f.read(4) #reading the magic number and version... Then throwing it away.
   expected_sizes=[48,380,58,20,96,44,13,17,5,63,23]
   #sf_system_file=SfSystemFile.new()
   #sf_system_file.save()
   #current_state[:system_file_id]=sf_system_file.id
   current_state[:system_file_id]=nil
   parsing_file=true
   until !parsing_file || f.eof?
      block_pos=f.pos
      block_type = f.read(2).unpack('S')[0]
      block_size = f.read(2).unpack('S')[0]
      output << block_type.to_s << "," << block_size.to_s
      output << "---------------------------\nPos: #{block_pos}  Block Type: #{block_type} Block Size: #{block_size} <br>"
      if block_type == 65535
         parsing_file=false
         #return [sf_id,output]
      elsif block_type > 20
        output << "skipping Block<br>"
      else
        output << "reading Block<br>"
         #puts expected_sizes[block_type].to_s + "|"+f.pos.to_s+ "|" +block_type.to_s + "|" + block_size.to_s + "\n"
         if (expected_sizes[block_type] != block_size)
            raise SFParserError, 
               "Block #{block_type} expectected length(#{expected_sizes[block_type]})!= Actual length (#{block_size.to_s})"
         end
         block=f.read(block_size)
         if (block_type == 0) #System File
            data=parse_type0(block)
            current_state[:system_file_data]=data
         elsif (block_type == 1) #Channel Plan Header
            data=parse_type1(block)
            sf_system_file=get_system_file(data[:guid])
            current_state[:system_file_id]=sf_system_file.id
            sf_system_file.system_name=current_state[:system_file_data][:name]
            sf_system_file.channel_plan_name=data[:name]
            sf_system_file.description=data[:descr]
            sf_system_file.author=data[:author]
            sf_system_file.guid=data[:guid]
            if (display_name.nil?)
               sf_system_file.display_name=current_state[:system_file_data][:name]
            else
               sf_system_file.display_name=display_name
            end
            sf_system_file.save()
         elsif (block_type == 2) #Channel Header
            data=parse_type2(block)
            sf_channel=SfChannel.find(:first, :conditions=> 
              ["sf_system_file_id=? and channel_number=?",current_state[:system_file_id],data[:number]])
            if (sf_channel.nil?)
               sf_channel=SfChannel.new()
               sf_channel.sf_system_file_id=current_state[:system_file_id]
               sf_channel.channel_number=data[:number]
            end
            sf_channel.channel_type=data[:type]
            sf_channel.channel_name=data[:name]
            sf_channel.direction=data[:direction]
            sf_channel.use_full_scan=data[:usefullscan]
            sf_channel.use_miniscan=data[:useminiscan]
            sf_channel.active=data[:active]
            sf_channel.unit_type=data[:unitType]
            sf_channel.save()
            current_state[:channel_id]=sf_channel.id
         elsif (block_type == 3)
            data=parse_type3(block)
            if (!current_state.key?(:channel_id))
               raise("Current State of channel is failing")
            end
            sf_channel=SfChannel.find(current_state[:channel_id])
            sf_channel.channel_dtls=data
            sf_channel.save()
         elsif (block_type == 4)
            data=parse_type4(block)
            if (!current_state.key?(:channel_id))
               raise("Current State of channel is failing")
            end
            sf_channel=SfChannel.find(current_state[:channel_id])
            sf_channel.channel_dtls=data
            sf_channel.save()
         elsif (block_type == 5)
            data=parse_type5(block)
            #current_state[:system_file_id]=get_system_file_id(data[:guid])
            sf_test_plan=SfTestPlan.find(:first, :conditions=>
               " sf_system_file_id=#{current_state[:system_file_id]} and test_plan_ident=#{data['id']} ")
            if (sf_test_plan.nil?)
               sf_test_plan=SfTestPlan.new()
               sf_test_plan[:sf_system_file_id]=current_state[:system_file_id]
               sf_test_plan[:test_plan_ident]=data['id']
            end
            sf_test_plan["name"]=data['name']
            sf_test_plan.save()
            current_state[:test_plan_id]=sf_test_plan.id
         elsif (block_type == 6)
            data=parse_type6(block)
            filter=" sf_system_file_id=#{current_state[:system_file_id]} and channel_number=\"#{data['channel']}\""
            channel=SfChannel.find(:first, :conditions=>filter)
            if (channel.nil?)
               output << "Skipped: Channel: #{data['channel']} is not known"
            else
               #" sf_system_file_id=#{current_state[:system_file_id]} and test_plan_ident=#{data['id']} " +
               if current_state.key?(:test_plan_id)
               sf_test_channel=SfTestChannel.find(:first, :conditions=>
                  "sf_test_plan_id=#{current_state[:test_plan_id]} " + 
                    " and sf_channel_id=#{channel.id} " +
                    " and test_type=#{data['testtype']}")
               else
                  raise "We have a bigger problem"
               end
               if (sf_test_channel.nil?)
                  sf_test_channel=SfTestChannel.new()
                  sf_test_channel.sf_test_plan_id=current_state[:test_plan_id]
                  sf_test_channel.sf_channel_id=channel.id
                  sf_test_channel.test_type=data['testtype']
               end
               sf_test_channel.enable_flag=data['enable']
               sf_test_channel.sf_test_plan_id=current_state[:test_plan_id]
               sf_test_channel.save()
            end

         elsif (block_type == 7)
            data=parse_type7(block)
               sf_system_test=SfSystemTest.find(:first, :conditions=>
                  " sf_test_plan_id=#{current_state[:test_plan_id]} and test_type=#{data['testtype']}")
               if (sf_system_test.nil?)
                  sf_system_test=SfSystemTest.new()
                  sf_system_test.test_type=data['testtype']
                  sf_system_test.sf_test_plan_id=current_state[:test_plan_id]
               end
               sf_system_test.enable_flag=data['enable']
               sf_system_test.data_type=data['datatype']
               if (data['minvalue']==-32768)
                  sf_system_test.min_value=nil
               else
                  sf_system_test.min_value=data['minvalue']
               end
               if (data['maxvalue']==-32768)
                  sf_system_test.max_value=nil
               else
                  sf_system_test.max_value=data['maxvalue']
               end
               if (data['maxvalue']==0.0 && data['maxvalue'] < data['minvalue'])
                  sf_system_test.max_value=nil
             	 end
             	 if (data['minvalue']==0.0 && data['maxvalue'] < data['minvalue'])
                  sf_system_test.min_value=nil
             	 end	
               if (data['tolerance']==-32768)
                  sf_system_test.tolerance=nil
               else
                  sf_system_test.tolerance=data['tolerance']
               end
               sf_system_test.units=data['units']
               sf_system_test.save()
               output << data.inspect()
         elsif (block_type == 8)
            data=parse_type8(block)
         elsif (block_type == 9)
            data=parse_type9(block)
            sf_setup=SfSetup.find(:first, :conditions=>
               " sf_system_file_id=#{current_state[:system_file_id]} and setup_type=#{data['setuptype']}")
            if (sf_setup.nil?)
               sf_setup=SfSetup.new()
               sf_setup.setup_type=data['setuptype']
               sf_setup.sf_system_file_id=current_state[:system_file_id]
            end
            sf_setup.data_type=data['datatype']
            sf_setup.value=data['value']
            sf_setup.save()
         elsif (block_type == 10)
					 #Just ignore block type 10
         else
            output << "Nothing For "+block_type.to_s+"<br>"
         end 
      end 
  end
  f.close
  sf_id=current_state[:system_file_id]
  # Go through each SfTestPlan and verify the SfTestChannels are setup
  @sf_test_plans = SfTestPlan.find(:all, :include => [:sf_test_channels], :conditions => ["sf_system_file_id = ?", sf_id])
  @sf_channels = SfChannel.find(:all, :conditions => ["sf_system_file_id = ?", sf_id])
  @sf_test_plans.each { |sf_test_plan|
    @sf_channels.each { |sf_channel|
      if sf_test_plan.sf_test_channels.find(:first, :conditions => ["sf_channel_id = ?", sf_channel.id]).nil?
        # SfTestChannel doesn't exist, create it.
        sf_test_channel = SfTestChannel.new(
          :sf_test_plan_id => sf_test_plan.id, 
          :test_type => 100, 
          :enable_flag => false, 
          :sf_channel_id => sf_channel.id
        )
        sf_test_channel.save
      end
    }
  }
  return [sf_id,output]
end
#remove this check in order not to identify system file by system file guid.
def SFParser::get_system_file(guid)
   #sf_system_file=SfSystemFile.find(:first,:conditions=> "guid=\"#{guid}\"")
   #if (sf_system_file.nil?)
      sf_system_file=SfSystemFile.new()
      sf_system_file.save()
   #end
   return sf_system_file
end


#load(system_file)
end
end
