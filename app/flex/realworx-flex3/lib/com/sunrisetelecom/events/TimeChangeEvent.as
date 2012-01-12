package com.sunrisetelecom.events
{
    import flash.events.Event;

    public class TimeChangeEvent extends Event
    {
        public static var TIME_CHANGE:String = "TIME CHANGE";
        
        public function TimeChangeEvent()
        {
            super(TIME_CHANGE, true, false);
        }
    }
}