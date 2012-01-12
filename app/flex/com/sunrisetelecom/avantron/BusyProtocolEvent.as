package com.sunrisetelecom.avantron
{
    import flash.events.Event;

    public class BusyProtocolEvent extends Event
    {
        public var event:String;
        public var expect:String;
        public var msg:String;
        public static const BUSY:String="Busy";

        public function BusyProtocolEvent(type:String, expect:String,msg:String="Busy",bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this.event=type;
            this.expect=expect;
            this.msg=msg;
        }
    }
}