package com.sunrisetelecom.events
{
    import flash.events.Event;

    public class SelectChangeEvent extends Event
    {
        public static var LEFT_CHANGE:String = "LEFT CHANGE";
        public static var RIGHT_CHANGE:String = "RIGHT CHANGE";
        
        private var _count:uint = 0;
        
        public function SelectChangeEvent(type:String)
        {
            super(type, true, false);
        }
        
        public function get count():uint
        {
            return _count;
        }
        public function set count(c:uint):void
        {
            _count = c;
        }
        
    }
}