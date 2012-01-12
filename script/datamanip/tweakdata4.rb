#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require "statistics2"
require "date"
require "ar-extensions"
ts = Time.now
mincount =60*24*30
end_date=Time.now-mincount.minutes
while (ts> end_date)
   ts=ts-1440.minutes
   1.upto(4) { |switch_port_id|
         
         start_fq=5000000
         stop_fq=50000000
         dl=Datalog.create(:switch_port_id=>switch_port_id, :start_freq => start_fq, :stop_freq => stop_fq, :ts => ts, :attenuation=> 15, :sample_count => 10);
         puts dl.inspect()
         bw=(stop_fq-start_fq)/499
         dtls=[]
         500.times {|idx|
            freq=((bw*idx+start_fq)/10000.0).round*10000
            dtls.push([freq, rand(20)-22,rand(10)-20,rand(15)-20,dl.id])
            }
            DatalogDtl.import([:freq, :max_val,:min_val,:val,:datalog_id],dtls)
         puts "Data for #{dl.id}"
   }
end
