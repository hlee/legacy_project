package com.sunrisetelecom.events
{
	import flash.events.Event;

	public class BusyEvent extends Event
	{
		public var msg:String = "";
		
		public function BusyEvent(type:String,msg:String = "", bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.msg = msg;
		}
		
		public static const START_BUSY:String = "startBusy";
		public static const STOP_BUSY:String = "stopBusy";
	}
}