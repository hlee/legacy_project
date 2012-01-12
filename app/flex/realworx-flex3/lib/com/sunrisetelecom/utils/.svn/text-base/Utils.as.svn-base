package com.sunrisetelecom.utils
{
    import flash.utils.ByteArray;
    
    public class Utils
    {
        import mx.utils.ObjectProxy;
        
        public static function convertToFixedNumber(data:Number, digits:uint):Number
        {
            return Number(data.toFixed(digits));
        }
        
        public static function convertArray(data:Array):Array
        {
            for(var i:String in data) data[i] = new ObjectProxy(data[i]);
            return data;
        }
        
        public static function clone(source:Object):*
        {
            var myBA:ByteArray = new ByteArray();
            myBA.writeObject(source);
            myBA.position = 0;
            return(myBA.readObject());
        }
        
        public static function getDateTimeString(d:Date):String
        {
            var year:String = d.fullYear.toString();
            
            var month:String = (d.month + 1).toString();
            
            var date:String = d.date.toString();
            
            var hour:String = ((d.hours > 9) ? "" : "0") + d.hours.toString();
            
            var minute:String = ((d.minutes > 9) ? "" : "0") + d.minutes.toString();
            
            var second:String = ((d.seconds > 9) ? "" : "0") + d.seconds.toString();
            
            return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second;
        }
        
        public static function floatComparator(s1:String, s2:String):int
        {
            if(s1 == null || s2 == null) return 0;
            
            try
            {
                var n1:Number = parseFloat(s1);
                var n2:Number = parseFloat(s2);

                if(isNaN(n1) || isNaN(n2) || (n1 == 0 && s1 != "0") || (n2 == 0 && s2 != "0"))
                {
                    if(s1 > s2) return 1;
                    
                    if(s1 < s2) return -1;
                    
                    return 0;
                }
                
                if(n1 > n2) return 1;
    
                if(n1 < n2) return -1;
            }
            catch(e:Error)
            {
                trace("Error in Comparator: " + e.message);
            }
            return 0;
        }

    }
}