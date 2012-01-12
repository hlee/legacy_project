package com.sunrisetelecom.avantron
{
    public class Queue extends Object
    {
        private var quedata:Array=new Array();
        
        public function put(obj:Object):void
        {
            quedata.push(obj);
        }
        
        public function get():Object
        {
            return quedata.shift();
        }
        
        public function peek():Object
        {
            return quedata[0];
        }
        
        public function length():int
        {
            return quedata.length;
        }
        
        public function Queue()
        {
            //TODO: implement function
            super();
        }
    }
}
