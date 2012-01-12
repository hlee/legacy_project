#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "statistics2"
require "date"
require "ar-extensions"

Datalog.find(:all).each { |dl|
   min=dl.min_image
   max=dl.max_image
   img=dl.image
   start_fq=dl.start_freq
   stop_fq=dl.stop_freq
   bw=stop_fq-start_fq
   dtls=[]
   500.times {|idx|
      freq=((bw*idx+start_fq)/10000.0).round*10000
      #      ex.exdatalog_dtls.create(:freq=>freq, 
      #   :max_val =>dl.max_image[idx],
      #   :min_val => dl.min_image[idx], :val =>dl.image[idx],
      #   :ts =>dl.ts)
      dtls.push([freq, dl.max_image[idx],dl.min_image[idx],dl.image[idx],dl.ts,dl.id])
   }
   datalogDtl.import([:freq, :max_val,:min_val,:val,:ts,:datalog_id],dtls)
   puts "Data for #{ex.id}"
}
