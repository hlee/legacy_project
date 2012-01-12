package com.sunrisetelecom.events
{
    import flash.display.InteractiveObject;
    import flash.events.MouseEvent;

    public class CustomMouseEvent extends MouseEvent
    {
        public static const CUSTOM:String = "CUSTOM";
        
        private var _customObject:Object = null;
        
        override public function get type():String
        {
            return CUSTOM;
        }
        
        public function CustomMouseEvent(type:String = CUSTOM, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=NaN, localY:Number=NaN, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0)
        {
            super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
        }
        
        public function get customObject():Object
        {
            return _customObject;
        }
        public function set customObject(object:Object):void
        {
            _customObject = object;
        }
        
    }
}