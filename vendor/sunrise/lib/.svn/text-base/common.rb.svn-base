

#Loading global Ruby modules
require 'yaml'
require 'date'
require 'rubygems'
require 'logger'
require 'timeout'
require 'zlib'
require 'digest/md5'
require 'digest/sha1'




# Add to the load path the root server directory
$:.push(File.expand_path(File.dirname(__FILE__ ))+ "/../lib")

# We pull config info (like where the rails app is) and set our 
# library load path.
require 'config_info'
cfg_info=ConfigInfo.instance()
require 'monitoring_files'
require 'avantron'
require 'block_file'
require 'instrument_session'

# Now that we have the rails_home directory in the path we start
# loading application specific modules.
#require 'app/models/analyzer'
cfg_info.init_data() #Can't run this function until we have analyzers defined
#require "app/models/schedule"
#require "app/models/scheduled_source"
#require "app/models/analyzer"
#require "app/models/switch"
#require "app/models/switch_port"
#require "vendor/sunrise/lib/image_functions"
#require "app/models/datalog"
#require "app/models/alarm"
#require "app/models/profile"
#require "app/models/config_param"
#require "vendor/sunrise/lib/image_functions"
#require "app/models/channel"
#require "app/models/measure"
#require "app/models/measurement"
#require "app/models/system_log"
#require "app/models/sf_test_plan"
#require "app/models/sf_test_channel"
#require "app/models/sf_channel"
#require "app/models/sf_system_file"

module Common
      # ===parse_image()
      # <b>Class Function</b>
      # This can take a trace image in the compressed 8bit format and convert it to a 10 bit format
      def Common.parse_image(raw_image)
         raise("Image[#{raw_image.length}] is not 625  numbers long, ") if (raw_image.length != 625)
         image= Array.new()
         125.times {|i|
            image[4*i]= (raw_image[5*i] << 2)| (raw_image[5*i+1]>>6)
            image[4*i+1]= ((raw_image[5*i+1] & 0x3F) << 4)| (raw_image[5*i+2]>>4)
            image[4*i+2]= ((raw_image[5*i+2] & 0xF) << 6)| (raw_image[5*i+3]>>2)
            image[4*i+3]= ((raw_image[5*i+3] & 0x3)<< 8)| (raw_image[5*i+4]>>0)
         }
         #puts image.inspect()
         return image
      end
      # ===pack_image()
      # <b>Class Function</b>
      # This can take a uncompressed 10 bit image and compress it to the 8 bitformat
      def Common.pack_image(image_array)
         raise("Image[#{image_array.length}] is not 500  numbers long") if (image_array.length != 500)
         image= String.new()
         image_arr=[]
         125.times {|i|
            raise "element at #{4*i} is not an integer | #{image_array[4*i+1].to_i}" if !image_array[4*i].integer?
            raise "element at #{4*i+1} is not an integer | #{image_array[4*i+1].to_i}" if !image_array[4*i+1].integer?
            raise "element at #{4*i+2} is not an integer | #{image_array[4*i+1].to_i}" if !image_array[4*i+2].integer?
            raise "element at #{4*i+3} is not an integer | #{image_array[4*i+1].to_i}" if !image_array[4*i+3].integer?
            image_array[4*i]=1023 if image_array[4*i].to_i >=1024
            image_array[4*i+1]=1023 if image_array[4*i+1].to_i >=1024
            image_array[4*i+2]=1023 if image_array[4*i+2].to_i >=1024
            image_array[4*i+3]=1023 if image_array[4*i+3].to_i >=1024
            image_arr[5*i]= ((image_array[4*i]>>2) & 0xFF)
            image_arr[5*i+1]=  (((image_array[4*i] << 6) & 0x00C0) | ((image_array[(4*i)+1] >> 4) &0x003F))
            image_arr[5*i+2]= (((image_array[4*i+1] << 4) & 0x00F0) | ((image_array[(4*i)+2] >> 6) &0x000F))
            image_arr[5*i+3]= (((image_array[4*i+2] << 2) & 0x00FC) | ((image_array[(4*i)+3] >> 8) &0x0003))
            image_arr[5*i+4]= ((image_array[4*i+3] & 0x00FF) )
         }
         image=image_arr.pack('C*')
         return image
      end

      #def Common.init_crc_table
      #dwPolynomial=0xEDB88320
      #@@crctable=[]
      #256.times { |i|
         #dwCrc = i;
         #8.times { |bit|
            #if (dwCrc & 1)
            #puts ""
            #dwCrc =(dwCrc >> 1) ^ dwPolynomial;
            #else
            #dwCrc >>=1;
            #end
            #}
            #@@crctable[i]=dwCrc
            #puts "#{i},#{dwCrc} dwCrc"
            #}
            #end
            #def Common.calc_crc32(chr, dwCrc32)
         #Xputs "> #{chr} #{chr^dwCrc32 & 0x000000FF}/#{@@crctable[chr^dwCrc32 & 0x000000FF]}"
         #return ( (dwCrc32 >> 8) ^ @@crctable[chr ^ (dwCrc32 & 0x000000FF)])
         #end

      def Common.calc_crc32_for_str(str)
         return Zlib.crc32(str)
      end
   def Common.gen_hsh(file_path)
      hasher = Digest::MD5.new
      str=''
      open(file_path, "r") do |io|
         counter = 0
         while (!io.eof)
            str << io.read()
         end
      end         
      return Zlib.crc32(str)
   end   
   end
