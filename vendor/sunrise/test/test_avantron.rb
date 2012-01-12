#!/usr/bin/ruby

$base_dir = File.expand_path(File.dirname(__FILE__))
$:.push($base_dir+"/..")
puts $:
require 'lib/common'
#require '../lib/avantron'
#require '../lib/config_info'
require 'test/unit'

class AvantronTest < Test::Unit::TestCase
   def test_image_pack
      data=[]
      500.times { |i| data[i]=i}
      data_image=Common.pack_image(data)
      data_result=Common.parse_image(data_image)
      assert 500,data_image.length
      assert 625,data_result.length
      assert data_result.max,499
      data[23]=102004
      #      Avantron.pack_image(data)
       assert_raise(RuntimeError) do  
          Common.pack_image(data)
       end
      data[23]=4
      data[22]=1024
      #      Avantron.pack_image(data)
       assert_raise(RuntimeError) do  
          Common.pack_image(data)
       end
      data[22]=4
      data[21]=1024
      #      Avantron.pack_image(data)
       assert_raise(RuntimeError) do  
          Common.pack_image(data)
       end
      data[21]=4
      data[20]=1024
      #      Avantron.pack_image(data)
       assert_raise(RuntimeError) do  
          Common.pack_image(data)
       end
   end

   def test_crc32
   end

   def test_comm #This requires a config file
      logger=Logger.new('test.log')
      data_file="#{$base_dir}/../test/testdata/instrument.yml"
      if (File.file? data_file)
         @data=YAML.load_file(data_file)
         puts "---"
         puts @data[:comm][:ip]
         puts "---"
      else
         puts "Skipping Communications Test"
         return
      end
      content=''
      open(data_file,'r') {|f| content=f.read}
      #Common.init_crc_table()
      calc_crc=Common.calc_crc32_for_str(content)
      instrument=InstrumentSession.new(@data[:comm][:ip],'3001','10',logger)
      assert !instrument.nil?
      instrument.initialize_socket()
      instrument.login()
      instrument.upload_file(data_file,'/tmp/data')
      instrument.download_file('/tmp/data','/tmp')
      result=instrument.get_file_crc32('/tmp/data')
      puts result.inspect()
      assert result.msg_object['crc32']==calc_crc
      instrument.logout()
      instrument.close_session()
   end

   def teardown
   end
end
