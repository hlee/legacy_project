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

2.upto(30) { |ch|
   if freq_lookup[ch].nil?
      freq_lookup[ch]={}
      freq_lookup[ch][:freq]=freq_lookup[ch-1][:freq]+6
   end
}
puts freq_lookup.inspect
