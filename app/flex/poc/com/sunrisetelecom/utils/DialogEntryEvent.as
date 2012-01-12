package com.sunrisetelecom.utils
{
	import flash.events.Event;

	public class DialogEntryEvent extends Event
	{
		public var m_data:Object;
		public function DialogEntryEvent(type:String,data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			m_data=data;
		}
		
	}
}
