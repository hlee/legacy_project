#!/usr/bin/ruby
require 'webrick'
include WEBrick
$:.push(File.expand_path(File.dirname(__FILE__))+"/../../../../vendor/sunrise/lib")
require File.dirname(__FILE__) + "/../../../../config/environment"
require 'common'
require 'config_files'
require 'utils'
require 'instr_utils'
include ImageFunctions

#Variable definitions
$instr_session=nil
$previous_hmid=nil
$logger=Logger.new("#{RAILS_ROOT}/log/clearpath.out")
$analyzer_list=[]
$instructions= <<INSTRUCT
<html>
<head>
</head>
<body>
<h2> Videotron's Clearpath/Realworx Interface</h2>
<h3> Description</h3>
This daemon provides an external interface to Videotron for their SGVR server. This daemon allows the saving of traces captured from realview for a paticular site. 
These traces are associated with paticular clearpath devices, their state and their location through the description field of the snapshot.  Snapshots are grouped together in sessions.  A session can have one baseline.  <p>
Below I will go through a typical session creation that the SGVR server might go through. The daemon running on port 3001 is named clearbath.rb

<ul>
<li> Step 1. User clicks on a link from the links page of realworx.  This will make a http call to the SGVR server giving it a site_name and a session name.  The link will be a bookmarklet that will contain a date_time for session and prompt for the site_name.</li>
<li> Step 2. SGVR server makes a call back to the clearpath.rb daemon to request a trace (http://ip:3001/trace/new?site_name=anl//x&session_id=D20090601101010)</li>
<li> Step 3. clearpath.rb pulls a trace and stores it as a snapshot using the session_id. Since no device is specified it assumes this is a baseline</li>
<li> Step 4. SGVR turns on a clearpath device then makes a call back to the Clearpath server to request a trace  specifying what the device name, location and status is.(http://ip:3001/trace/new?site_name=anl//x&session_id=D20090601101010&device_name=x1&device_status=open&device_location=here)</li>
<li> Step 5. clearpath.rb pulls a trace and stores it as a snapshot using the session_id. Since device details are specified then clearpath will store as baseline=no</li>
<li> Step 6. If more devices exists go to step 4.</li>
<li> Step 7. User should be able to go into snapshots.  Select session and review traces. If baseline exist then display baseline on all traces as well.</li>
</ul>

<h3> Definition of Interface</h3>
   There are 3 command requests supported by this application.
<ul>
<li> '/' or '/help'    -  displays this screen</li>
<li> '/trace/new'      -  Store a Trace</li>
<li> '/session/close'  -  Close and validate a session</li>
<p/>
<pre>
trace/new has two required parameters and 3 optional parameters
  Required ['session_id', 'site_name']
  Optional ['device_name','device_state', 'device_location'])
  All are text.  The only item that is validated is site_name. It must be a site name recognized by the system.
</pre>
<p/>

	</body>
</html>
INSTRUCT



#WEBRICK SETUP
s = HTTPServer.new( :Port => 3002 )

s.mount_proc("/"){|req, res|
  res.body = '<document>
  <status code="0">Open Session</status>
  <session>334422 </session>
  <error>
    <message>User Name not recognized</message>
  </error>
</document>'
  res['Content-Type'] = "text/xml"
  puts "got session new"
}


trap("INT"){ s.shutdown }
s.start
