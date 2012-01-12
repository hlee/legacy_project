package com.sunrisetelecom.controls
{
    import mx.collections.*;
    
    public class ProfileMap extends ArrayCollection
    {
        private var _lastAddedX:Number;
        private var _firstMark:Boolean = true;
        
        public function ProfileMap()
        {
            var sort:Sort=new Sort();
            sort.fields = [new SortField("dataX",true)];
            sort.compareFunction = sortfunc;
            this.sort = sort;
        }
        
        public function firstMark():void
        {
            _firstMark = true;
        }
        
        private function sortfunc(item:Object, item2:Object, fields:Array = null):int
        {
            if(Number(item.dataX) < Number(item2.dataX))
            {
                return -1;
            }    
            else if(Number(item.dataX) > Number(item2.dataX))
            {
                //Alert.show(item.dataX,"---",item2.dataX);
                return 1;
            }
            else
            {
                return 0;
            }
        }
        
        override public function removeAll():void
        {
            super.removeAll();
            
            firstMark();
        }
        
        override public function addItem(item:Object):void
        {
            if(!item.hasOwnProperty('dataX'))
            {
                return;
            }
            
            if(_firstMark == true)
            {
                _firstMark = false;
                _lastAddedX = item.dataX;

                return;
            }
            
            var start_remove:Number = item.dataX;
            var stop_remove:Number = item.dataX;
            
            //Code assumes that last_added_x has been set at least once.
            if(_lastAddedX <item.dataX)
            {
                   start_remove = _lastAddedX;
            }
            else if(_lastAddedX > item.dataX)
            {
                stop_remove = _lastAddedX;
            }
            
            //The only way last_added_x would not be set is if the length of the array == 0
            for(var i:int = this.length - 1; i >= 0; i--)
            {
                if(this[i].dataX == item.dataX)
                {
                    this.removeItemAt(i);
                }
                else if((this[i].dataX > start_remove) && (this[i].dataX < stop_remove))
                {
                    this.removeItemAt(i);    
                }
                else if(this[i].dataX < start_remove)
                {
                    i = -1;
                }
            }
            
            super.addItem(item);
            
            _lastAddedX = item.dataX;
            
            this.refresh();
        }
    }
}