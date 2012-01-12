#!/usr/bin/ruby
ENV['RAILS_ENV']='test'
require 'digest/md5'
require 'digest/sha1'
$BUF_SIZE = 1024*1024*1024


$base_dir = File.expand_path(File.dirname(__FILE__))
$:.push($base_dir+"/..")
puts $base_dir
require 'lib/common'
require 'test/unit'

class MonitoringFileTest < Test::Unit::TestCase
  fixtures :config_params
   def setup
      ci=ConfigInfo.instance()
      Analyzer.delete_all()
      SwitchPort.delete_all()
      Switch.delete_all()
      # Build Analyzers
      anl_attr= {
         :name=>'Headend Spectrum',:location=>'Bobs house',:ip=>'10.0.0.35',
         :switch_network=>1,
         :baud_rate=>115200,:switch_type=>0,:bidirectional_flag=>1,
         :port_nbr=> 0, :port_count=>16, :attenuator=>15,
         :ref_offset=>0,:resol_bwd=>300000.0,
         :video_bwd=>100000.0
      }
      Analyzer.create anl_attr
      anl=Analyzer.find(:first)
      # Build Switches
      sw_attr={ 
         :analyzer_id=>anl.id, :master_switch_src=>-1,
         :switch_name=>'Multiplexer',:port_count=>16, :switch_ident=>nil,
         :location=>'Bobs Switch', :address=>1,
         :baud_rate=>115200
      }
      sw=Switch.create sw_attr
      fake_trace=[]
      500.times{|i| fake_trace.push(-9.94) }
      prof={
         :name=>'NewTrace',
         :comment=>'',
         :status=>1,
         :major_offset => 15,
         :minor_offset => 5,
         :loss_offset => -50,
         :link_loss=>1
         #:trace=>fake_trace.pack("S*")
      }
      profile=Profile.new prof
      profile.trace=fake_trace
      profile.save()
      16.times { |id|
         sp_attr={
            :switch_id=>sw.id, :name=>"port "+id.to_s, :port_nbr=>id,
            :stat_trace_flag=>0,  :site_id=>"X"+id.to_s,
            :profile_id => profile.id
         }
         sp=SwitchPort.create sp_attr
      }
   end

   def test_trace_reference
      input_file=$base_dir+"/testdata/monitor.ref"
      #puts input_file
      tr=MonitorFiles::MonitoringFile.read(input_file)
      assert_equal 16,tr.obj_list.length, "Expected 15 signal points"
      assert_equal "NewTrace\000",tr.obj_list[0].name
      assert_equal 41,tr.obj_list[0].comment.length
      assert_equal 0,tr.obj_list[0].comment.strip.length
      assert_equal 18,tr.obj_list[0].tm.length
      assert_equal 0,tr.obj_list[0].tm.strip.length
      assert_equal 0,tr.obj_list[0].temp_external
      assert_equal 0,tr.obj_list[0].current_mode
      assert_equal 10,tr.obj_list[0].attenuation
      assert_equal 0,tr.obj_list[0].if_offset
      assert_equal 0,tr.obj_list[0].ref_offset
      assert_equal 20,tr.obj_list[0].at2000status[:sweep_time]
      assert_equal 25000000.0,tr.obj_list[0].center_freq
      assert_equal 500,tr.obj_list[0].trace.length
      #puts tr.obj_list[0].trace.inspect()
      assert_equal 300000,tr.obj_list[0].at2000status[:resol_bwd]
      assert_equal 40000000,tr.obj_list[0].at2000status[:span]
      tr.write('/tmp/bacon.ref')
      result_file_md5=hsh('/tmp/bacon.ref')
      input_file_md5=hsh(input_file)
      #Verify that the file we generate is the same that we read.
      assert result_file_md5 == input_file_md5
      first_anl=Analyzer.find(:first)
      obj_list=MonitorFiles::TraceReferenceFO::build(first_anl.id)

      trace_file=MonitorFiles::MonitoringFile::new()
      trace_file.obj_list=obj_list
      #puts obj_list[0].inspect()
      trace_file.write("/tmp/generated_trace.ref")
      result_file_md5=hsh('/tmp/generated_trace.ref')
      orig_file_md5=hsh($base_dir+'/testdata/monitor2.ref')
      assert result_file_md5 == orig_file_md5
      puts result_file_md5

   end
   def hsh(file_path)
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
