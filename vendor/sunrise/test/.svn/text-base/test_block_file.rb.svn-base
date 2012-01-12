#!/usr/bin/ruby
require 'digest/md5'
require 'digest/sha1'
$BUF_SIZE = 1024*1024*1024


$base_dir = File.expand_path(File.dirname(__FILE__))
$:.push($base_dir+"/..")
puts $base_dir
require 'lib/block_file'
require 'test/unit'

class BlockFileTest < Test::Unit::TestCase
   def test_channel_plan
      input_file=$base_dir+"/testdata/sunrise.acp"
      #input_file=$base_dir+"/tmp/sunrise.acp"
      bfp=BlockFile::BlockFileParser.new()
      bfp.load(input_file)
      #puts bfp.inspect()
      #puts bfp.block_list.length
      assert_equal 2210, bfp.block_list.length
      bfp.save('/tmp/generated.acp')
      assert md5(input_file)==md5('/tmp/generated.acp')
   end
   def test_hw_config
      input_file=$base_dir+"/testdata/hardware.cfg"
      bfp=BlockFile::BlockFileParser.new()
      bfp.load(input_file)
      bfp.block_list.each { |blk|
         puts blk.inspect()
         puts "-----------"
      }
      assert_equal 18, bfp.block_list.length
      bfp.save('/tmp/generated.cfg')
      assert md5(input_file)==md5('/tmp/generated.cfg')
   end
   def test_ingress_setup
      input_file=$base_dir+"/testdata/sunrise.itp"
      bfp=BlockFile::BlockFileParser.new()
      bfp.load(input_file)
      assert_equal 148, bfp.block_list.length
      bfp.save('/tmp/generated.itp')
      assert md5(input_file)==md5('/tmp/generated.itp')
   end
   def md5(file_path)
      hasher = Digest::MD5.new
      open(file_path, "r") do |io|
         counter = 0
         while (!io.eof)
            readBuf = io.readpartial($BUF_SIZE)
            putc '.' if ((counter+=1) % 3 == 0)
            hasher.update(readBuf)
         end
      end         
      return hasher.hexdigest
   end   

end
