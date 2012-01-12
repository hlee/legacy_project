package com.sunrisetelecom.avantron
{
    import flash.events.Event;

    public class RecvProtocolEvent extends Event
    {
        public var event:String;
        public var response_type:String;
        public var data:Object;
        public static const RECV:String = "RECV";
        
        public function RecvProtocolEvent(evt:String, response_type:String=null, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(RECV, bubbles, cancelable);
            this.event=evt;
            this.response_type=response_type;
            this.data=data;
        }
        
        public function update(evt:String, response_type:String=null, data:Object=null):RecvProtocolEvent
        {
            this.event=evt;
            this.response_type = response_type;
            this.data = data;
            return this;
        }
    }
}