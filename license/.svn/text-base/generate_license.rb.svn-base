#!/usr/bin/ruby -w
# generate_license.rb
#
# Ask the user a series of questions and then generate a license
# file based on their answers.

ingress_enabled = ""
performance_enabled = ""
mac_address = ""
expiration_date = ""
date_range = ""

def ask_for(str)
  print "#{str}: "
  ans = $stdin.gets.downcase.chomp
  return ans
end

ans = ask_for("Ingress enabled [Y/n]")
if ans.eql?('n')
  ingress_enabled = "disabled"
else
  ingress_enabled = "enabled"
end

ans = ask_for("Performance enabled [Y/n]")
if ans.eql?('n')
  performance_enabled = "disabled"
else
  performance_enabled = "enabled"
end

mac_address = `/sbin/ifconfig | grep HWaddr | cut -c39- | head -1`.chomp.strip
ans = ask_for("Your Mac Address [#{mac_address}]")
if ! ans.eql?('')
  mac_address = ans
end

puts "We'll now pick the expiration date."
ans = ask_for("In how many days should the license expire [365]")
if ans.eql?('')
  date_range = '365'
else
  date_range = ans
end
expiration_date = (Time.now + date_range.to_i * 3600 * 24).to_i
puts "Using #{Time.at(expiration_date).strftime("%d %b %Y")} as expiration date\n"

puts "Here's the info I have:\n\n"
puts "\tMac address: #{mac_address}"
puts "\tLicense Expiration: #{expiration_date} (#{Time.at(expiration_date).strftime("%d %b %Y")})"
puts "\tIngress: #{ingress_enabled}"
puts "\tPerformance: #{performance_enabled}\n\n"

ans = ask_for("Look ok? [Y/n]")
if ans.eql?('n')
  exit
else
  File.open("license.txt.#{$$}", "w") {|f|
    f.write("Mac address: #{mac_address}\n")
    f.write("License Expiration: #{expiration_date} (#{Time.at(expiration_date).strftime("%d %b %Y")})\n")
    f.write("Ingress: #{ingress_enabled}\n")
    f.write("Performance: #{performance_enabled}\n")
  }
  puts "License file license.txt.#{$$} created"
end

ans = ask_for("Would you like me to sign the license? [Y/n]")
if ans.eql?('n')
  exit
else
  `/usr/bin/gpg --clearsign license.txt.#{$$} < /dev/null`
  puts "License file should be in license.txt.#{$$}.asc"
  puts "You can check the license key by running the following:\n"
  puts "\t/usr/bin/gpg --verify license.txt.#{$$}.asc\n"
end
