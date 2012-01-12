#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "statistics2"
require "date"
require "ar-extensions"

Datalog.find(:all).each { |dl|
   start_fq=dl.start_freq
   stop_fq=dl.stop_freq
   puts dl.inspect()
   bw=(stop_fq-start_fq)/499
   dtls=[]
   500.times {|idx|
      freq=((bw*idx+start_fq)/10000.0).round*10000
      #      ex.exdatalog_dtls.create(:freq=>freq, 
      #   :max_val =>dl.max_image[idx],
      #   :min_val => dl.min_image[idx], :val =>dl.image[idx],
      #   :ts =>dl.ts)
      dtls.push([freq, rand(20)-22,rand(10)-20,rand(15)-20,dl.id])
   }
   DatalogDtl.import([:freq, :max_val,:min_val,:val,:datalog_id],dtls)
   puts "Data for #{dl.id}"
}
