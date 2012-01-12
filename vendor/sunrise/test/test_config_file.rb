#!/usr/bin/ruby

ENV['RAILS_ENV']='test'
begin
base_dir = File.expand_path(File.dirname(__FILE__))
$:.push(base_dir)
$:.push(base_dir+'/..')
require 'lib/config_info'
require 'lib/config_files'
require 'test/unit'

class ConfigFileTest < Test::Unit::TestCase
   def setup
      anal=Analyzer.new({:id=>1, :name=>"an1",:ip=>"10.0.0.35",
        :switch_network=>1, :baud_rate=>115200, :switch_type=>1,
        :bidirectional_flag=>1,:port_nbr=>0,:port_count=>16 })
      anal.save()
      sw1=Switch.new({:id=>1,:analyzer_id=>anal.id, :master_switch_flag=>0,
        :switch_name=>'sc', :port_count=>16, :baud_rate=>115200,
        :address=>2})
      sw1.save()
      16.times { |idx|
         id=idx+1
         sp=SwitchPort.new({:id=>id, :switch_id=>sw1.id, :name=>'PORT '+id.to_s,
            :port_nbr=>idx
         })
         sp.save()

      }
   end
   def test_load_content
      ci=ConfigInfo.instance()
      base_dir = File.expand_path(File.dirname(__FILE__))
      #ci.load_content("
      #rails_home: /usr/local/apache2/htdocs/realworx
      #rails_db: #{base_dir}/../test/database1.yml")
      #puts ENV['RAILS_ENV']
      anl=Analyzer.find(:first)
      assert ConfigFiles::HWFile.save(anl.id, "/tmp/hw.cfg")
      
   end
   def teardown
      Analyzer.delete_all()
      Switch.delete_all()
      SwitchPort.delete_all()
   end
end
rescue Exception => e
   puts "Exception: #{e.class}:#{e.message}\n\t #{e.backtrace.join("\n\t")}"
   exit 1
   end
