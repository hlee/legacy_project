package com.sunrisetelecom.controls
{
    import mx.charts.series.LineSeries;
    import mx.charts.HitData;
    import mx.charts.series.items.LineSeriesItem;
    import mx.charts.chartClasses.CartesianTransform;
    
    import mx.graphics.IStroke;
    import mx.graphics.Stroke;
    import mx.graphics.LinearGradientStroke;
    
    public class ExtendedLineSeries extends LineSeries
    {
        public function ExtendedLineSeries()
        {
            super();
        }

        override public function findDataPoints(x:Number, y:Number, sensitivity:Number):Array
        {
            if(interactive == false || !renderData)
                return [];
    
            var pr:Number = getStyle("radius");
            var minDist2:Number = pr + sensitivity;
            minDist2 *= minDist2;
            var minItem:LineSeriesItem = null;     
            var pr2:Number = pr * pr;
            
            var len:int = renderData.filteredCache.length;
    
            if(len == 0)
                return [];
    
            if(sortOnXField == true)
            {            
                var low:Number = 0;
                var high:Number = len;
                var cur:Number = Math.floor((low + high) / 2);
        
                var bFirstIsNaN:Boolean = isNaN(renderData.filteredCache[0]);
        
                while(true)
                {
                    var v:LineSeriesItem = renderData.filteredCache[cur];          
                    if (!isNaN(v.yNumber) && !isNaN(v.xNumber))
                    {
                        var dist:Number = (v.x - x) * (v.x - x) + (v.y - y) * (v.y - y);
                        if(dist <= minDist2)
                        {
                            minDist2 = dist;
                            minItem = v;                
                        }
                    }
                    if(v.x < x || (isNaN(v.x) && bFirstIsNaN))
                    {
                        low = cur;
                        cur = Math.floor((low + high) / 2);
                        if(cur == low)
                            break;
                    }
                    else
                    {
                        high = cur;
                        cur = Math.floor((low + high) / 2);
                        if(cur == high)
                            break;
                    }
                }
            }
            else
            {
                var i:uint;
                for(i = 0; i < len; i++)
                {
                    v = renderData.filteredCache[i];          
                    if(!isNaN(v.yFilter) && !isNaN(v.xFilter))
                    {
                       dist = (v.x - x) * (v.x - x) + (v.y - y) * (v.y - y);
                       if(dist <= minDist2)
                       {
                           minDist2 = dist;
                           minItem = v;               
                       }
                    }
               }
            }
            
            if(minItem)
            {
                var hd:HitData = new HitData(createDataID(minItem.index), Math.sqrt(minDist2), minItem.x, minItem.y, minItem);
    
                var istroke:IStroke = getStyle("lineStroke");
                if(istroke is Stroke)
                    hd.contextColor = Stroke(istroke).color;
                else if(istroke is LinearGradientStroke)
                {
                    var gb:LinearGradientStroke = LinearGradientStroke(istroke);
                    if (gb.entries.length > 0)
                        hd.contextColor = gb.entries[0].color;
                }
                hd.dataTipFunction = formatDataTip;
                return [hd];
            }
    
            return [];
        }

        private function formatDataTip(hd:HitData):String
        {
            var dt:String = "";
            
            var n:String = displayName;
            if (n && n != "")
                dt += "<b>" + n + "</b><BR/>";
    
            var xName:String = dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).displayName;
            if (xName != "")
                dt += "<i>" + xName+ ":</i> ";
            dt += dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).formatForScreen(LineSeriesItem(hd.chartItem).xValue) + "\n";
            
            var yName:String = dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).displayName;
            if (yName != "")
                dt += "<i>" + yName + ":</i> ";
            dt += dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).formatForScreen(LineSeriesItem(hd.chartItem).yValue) + "\n";
            
            return dt;
        }
    }
}