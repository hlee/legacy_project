#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "statistics2"
require "date"
require "ar-extensions"
minago=38805
dt=minago.minutes.ago
Datalog.delete_all()
spid=33
while (minago > 15)
  Alarm.find(:all).each { |alm|
   val=alm.image.max
      max_image=alm.image.collect {|val| val+rand*2}
      min_image=alm.image.collect {|val| val-rand*2}
      image=alm.image
      dt=minago.minutes.ago
      if spid>48
            minago-=60
            spid=33
      end
      dl=Datalog.new(:ts=>dt, :sample_count=>30, :attenuation=>10, 
          :start_freq=>5000000, :stop_freq=>50000000, :switch_port_id=>spid)
      dl.min_image=min_image
      dl.max_image=max_image
      dl.image=image
      dl.save
      puts "> #{dl.id} [#{dt.to_s} ] #{spid} #{minago}"
      spid+=1
      if val > -16
         alm.delete
      end
  }
end
