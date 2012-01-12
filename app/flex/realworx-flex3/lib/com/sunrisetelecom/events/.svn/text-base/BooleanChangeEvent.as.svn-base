package com.sunrisetelecom.events
{
    import flash.events.Event;
    
    public class BooleanChangeEvent extends Event
    {
        public static var BOOLEAN_CHANGE:String = "BOOLEAN CHANGE";
        
        private var _value:Boolean = false;
        
        public function BooleanChangeEvent()
        {
            super(BOOLEAN_CHANGE, true, false);
        }
        
        public function get Value():Boolean
        {
            return _value;
        }
        
        public function set Value(val:Boolean):void
        {
            _value = val;
        }
    }
}