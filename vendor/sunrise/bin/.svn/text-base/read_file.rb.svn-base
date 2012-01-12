#!/usr/bin/ruby

require File.dirname(__FILE__) + "/../../../config/environment"
$:.push(File.expand_path(File.dirname(__FILE__))+"/../lib")
require 'rubygems'
require 'monitoring_files'
require 'block_file'
require 'common'
require 'logger'
$logger=Logger.new('/tmp/read_file.out')
fname = ARGV[0]
puts fname
if (fname =~ /cfg$/)
   bf=BlockFile::BlockFileParser.new()
   bfdata=bf.load(fname)
   puts bf.inspecter()
elsif (fname =~ /data.logging.buffer$/)
   bf=BlockFile::BlockFileParser.new()
   bfdata=bf.load(fname)
   puts bf.inspecter()
else
   mf=MonitorFiles::MonitoringFile.read(fname)
   puts mf.inspect()
end

