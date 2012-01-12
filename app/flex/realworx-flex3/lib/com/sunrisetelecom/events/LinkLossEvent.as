package com.sunrisetelecom.events
{
    import flash.events.Event;

    public class LinkLossEvent extends Event
    {
        public static var LINKLOSS_CHANGE:String = "LINKLOSS CHANGE";
        public static var LINKLOSS_SAVE:String = "LINKLOSS SAVE";
        
        private var _value:Number = NaN;
        private var _profileName:String = null;
        
        public function LinkLossEvent(type:String)
        {
            super(type, true, false);
        }
        
        public function get Value():Number
        {
            return _value;
        }
        public function set Value(val:Number):void
        {
            _value = val;
        }
        
        public function get profileName():String
        {
            return _profileName;
        }
        public function set profileName(p:String):void
        {
            _profileName = p;
        }
    }
}