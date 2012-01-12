#!/usr/bin/ruby

class SFParser
#system_file=ARGV[0]
#puts ("System File:" + system_file)
$chcount=0
$subchcount=0
$recent_ch=0
   

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
   $chcount=data[:num_channels].to_i
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
   puts "#{data['id']}, #{data['name']}"
   #dumphash(data)
   return data
end
def SFParser::parse_type6(block)
   unpacked_block=block.unpack('s5SC')
   i=0
   $subchcount+=1
   data={}
   data['channel']=unicode_string(unpacked_block[0..4])
   x=data['channel'].to_i
   #if ($recent_ch > x)
   #puts "Failed #{$recent_ch} > #{x}"
   #end
   $recent_ch=x
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
   expected_sizes=[48,380,58,20,96,44,13,17,5,63]
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
         elsif (block_type == 1) #Channel Plan Header
            data=parse_type1(block)
         elsif (block_type == 2) #Channel Header
            data=parse_type2(block)
         elsif (block_type == 3)
            data=parse_type3(block)
         elsif (block_type == 4)
            data=parse_type4(block)
         elsif (block_type == 5)
            data=parse_type5(block)
            #current_state[:system_file_id]=get_system_file_id(data[:guid])
         elsif (block_type == 6)
            data=parse_type6(block)
         elsif (block_type == 7)
            data=parse_type7(block)
         elsif (block_type == 8)
            data=parse_type8(block)
         elsif (block_type == 9)
            data=parse_type9(block)
         else
            output << "Nothing For "+block_type.to_s+"<br>"
         end 
         puts data.inspect()
         #puts "Channel Count #{$chcount}"
      end 
   end
   #puts "Final Channel Count #{$subchcount}/#{$chcount}"
   f.close
   sf_id=current_state[:system_file_id]
   return [sf_id,output]
end

end

SFParser.system_file_load(ARGV[0])
