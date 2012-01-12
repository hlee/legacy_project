package com.sunrisetelecom.controls
{
	public class AnalyzerPort
	{
		public var port_id:uint;
		private var _port_name:String;
		private var _site:String;
		public function AnalyzerPort(portid:uint, portname:String, site:String)
		{
			port_id = portid;
			_port_name = portname;
			_site = site;
			
		}
		public function set port_name(port:String):void
		{
			_port_name = port;
		}
		public function get port_name():String
		{
			return _port_name;
		}
		
		public function get site():String
		{
			return _site;
		}
		public function set site(site:String):void
		{
		    _site = site;
		}

	}
}