#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require "statistics2"
require "date"
require "ar-extensions"


#Take a measurement id, range of valuses, mean value, start date, end date and a paticular channel
#Build the values for date range and sites for that channel and that measurement.
def build_data(id, range, mean, start_date, end_date,ch_id)
   cols=[:measure_id, :site_id, :channel_id, :dt, :value]
   batch_data=[]
   start_date.upto(end_date) { |dt|
      puts "DATE #{dt}"
      Site.find(:all).each { |site|
         r=rand*2-1
            #Instead of a pure random value we use a normal distribution to get the values to crowd around the mean.
            val=Statistics2.normaldist(r)*range+(mean-range/2)
            batch_data <<[id, site.id,ch_id,dt,val]
            #measrec=Measurement.create(:measure_id => id, :site_id => site.id, 
            #:channel_id => ch.id, :dt => dt, :value => val)
         }
   }
   Measurement.import(cols, batch_data)#Mass importing of data. A lot faster than 1 insert at a time.
   #Put the limit writing code here.
end
def get_meas(name)
   meas=Measure.find(:first,:conditions=>"measure_name=\"#{name}\"")
   if (meas.nil?)
      meas=Measure.create(:measure_name=>name)
   end
   return meas
end

#This code builds the audio and video frequencies for the first 30 channels.
#Most channels are 6mhz apart but there are exceptions.  The following code is setting up the exceptions.
freq_lookup=[]
freq_lookup[2]={}
freq_lookup[2][:freq]=55.25
freq_lookup[5]={}
freq_lookup[5][:freq]=77.25
freq_lookup[7]={}
freq_lookup[7][:freq]=175.25
freq_lookup[8]={}
freq_lookup[8][:freq]=181.25
freq_lookup[14]={}
freq_lookup[14][:freq]=121.2625
freq_lookup[23]={}
freq_lookup[23][:freq]=217.35

#Now loop through thechannels and if the frequency is not set then add 6mhz to the previous frequency
2.upto(30) { |ch|
   if freq_lookup[ch].nil?
      freq_lookup[ch]={}
      freq_lookup[ch][:freq]=freq_lookup[ch-1][:freq]+6
   end
   #Audio frequencies are 4.5mhz above the video frequency.
   freq_lookup[ch][:aud]=freq_lookup[ch][:freq]+4.5

}
  


#Channel Build
Channel.delete_all()
#Create all Channels.  Assume sites are already built.
2.upto(30) {|ch|
   Channel.create(:channel_name => "CHAN#{ch}", :channel => ch)
}
start_date=Date.new(2007,01,01)
end_date=Date.new(2007,06,01)

#Analog Measure Build
Measure.delete_all()
#For each channel build each measurement's data.
ch=Channel.find(:all).each { |ch|
meas=get_meas('Video Level')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>10,:max_val=>25)
}
build_data(meas.id, 20,17.5, start_date, end_date, ch.id)
meas=get_meas('Video Freq')
#Use the channel frequency and generate a number within 1 Mhz of the original frequency.
chfreq=freq_lookup[ch.channel][:freq]
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>chfreq-0.00000001, :max_val=>chfreq+0.00000001)
}
build_data(meas.id, 0.000001,chfreq*1, start_date, end_date,ch.id)
meas=get_meas('V/A Ratio')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>-17, :max_val=>-10)
}
build_data(meas.id, 8,-13, start_date, end_date,ch.id)
meas=get_meas('Audio Freq')
audfreq=freq_lookup[ch.channel][:aud]
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>audfreq-0.0000001,:max_val=>audfreq+0.0000001)
}
build_data(meas.id, 0.0000001,audfreq*1, start_date, end_date,ch.id)
meas=get_meas('V/A2 Level')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>-17,:max_val=>-10)
}
meas=get_meas('Audio2 Freq')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>-17,:max_val=>-10)
}
meas=get_meas('Power Level')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>-17,:max_val=>-10)
}
build_data(meas.id, 100,5, start_date, end_date, ch.id)
meas=get_meas('CCN')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>35,:max_val=>nil)
}
build_data(meas.id, 35,52.5, start_date, end_date, ch.id)
meas=get_meas('CSO')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id, :min_val=>35,:max_val=>nil)
}
build_data(meas.id, 45,57, start_date, end_date, ch.id)
meas=get_meas('CTB')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id, :min_val=>35,:max_val=>nil)
}
build_data(meas.id, 45,57, start_date, end_date, ch.id)
meas=get_meas('Analog HUM')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id, :min_val=>nil,:max_val=>20)
}
build_data(meas.id, 10,5, start_date, end_date, ch.id)
meas=get_meas('Modulation Depth')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
build_data(meas.id, 30,7, start_date, end_date, ch.id)
}
#DIGITAL MEASUREMENT BUILD
meas=get_meas('Digital Channel Power')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>-10, :max_val=>10)
}
meas=get_meas('MER')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:min_val=>30)
}
meas=get_meas('Pre BER')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:max_val=>0.000001)
}
meas=get_meas('Post BER')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id,:max_val=>0.000001)
}
meas=get_meas('EVM')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('ENM')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('SNR')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('CI')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('ICFR')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('Echo Margin')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('Compression')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('Digital HUM')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('Phase Noise')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('IQ Gain Diff')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('IQ Phase Diff')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('Carrier Freq Err')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
meas=get_meas('Symbol Rate Err')
Site.find(:all).each { |site|
   limit=Limit.create(:measure_id=>meas.id, :channel_id=>ch.id, :site_id=> site.id)
}
