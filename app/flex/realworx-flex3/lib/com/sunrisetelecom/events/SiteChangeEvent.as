package com.sunrisetelecom.events
{
    import flash.events.Event;
    
    public class SiteChangeEvent extends Event
    {
        public static var SITE_CHANGE:String = "SITE CHANGE";
        
        private var _selectedSiteId:int = -1;
        
        public function SiteChangeEvent()
        {
            super(SITE_CHANGE, true, false);
        }
        
        public function get selectedSiteId():int
        {
            return _selectedSiteId;
        }
        
        public function set selectedSiteId(id:int):void
        {
        	_selectedSiteId = id;
        }
    }
}