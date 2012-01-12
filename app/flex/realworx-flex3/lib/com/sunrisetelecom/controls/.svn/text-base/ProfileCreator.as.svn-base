package com.sunrisetelecom.controls
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    
    import mx.charts.chartClasses.*;
    import mx.controls.*;
    import mx.utils.ObjectUtil;

    public class ProfileCreator extends ChartElement
    {
        //The points traced out so far
        private var _aDataPoints:Array;
        //Whether or not we are drawing
        private var _bTracking:Boolean;

        private var _label:Label;
        private var _tX:Number;
        private var _tY:Number;
        private var _bSet:Boolean;
        private var _profile:ProfileMap;

        private var _parent:DataLogViewer = null;

        /* the current position of the crosshairs */
        private var _crosshairs:Point;
        
        public function getProfileData():ProfileMap
        {
            return _profile;
        }
        
        public function clearProfileData():void
        {
            _profile.removeAll();
        }
        
        public function ProfileCreator():void
        {
            /*Create Label*/
            _label = new Label();
            addChild(_label);
            _profile = new ProfileMap();
        }
        
        public function startListening():void
        {
            addEventListener("mouseDown", markStartLocation);
            addEventListener("mouseMove", markLocation);
            addEventListener("rollOut", removeCrosshairs);
            addEventListener("mouseUp", markStopLocation);
            _bSet = true;
            invalidateDisplayList();
        }
        
        public function stopListening():void
        {
            removeEventListener("mouseDown", markStartLocation);
            removeEventListener("mouseMove", markLocation);
            removeEventListener("rollOut", removeCrosshairs);
            removeEventListener("mouseUp", markStopLocation);
            _bSet = false;
            invalidateDisplayList();
        }
        
        private function markStartLocation(e:MouseEvent):void
        {
            //_parent.addEventListener("mouseUp",markStopLocation,true);
            //_parent.addEventListener("mouseMove",track,true);
            _label.visible = true;
            _bTracking = true;
            _profile.firstMark();
            markLocation(e);
        }
        
        private function markStopLocation(e:MouseEvent):void
        {
            markLocation(e);
            _bTracking = false;
            
        }
        
        private function markLocation(e:MouseEvent):void
        {
            if(_parent == null) return;
            
            var dataVals:Array = dataTransform.invertTransform(mouseX,mouseY)
            _tX = dataVals[0];
            _tY = dataVals[1];
            _label.text = " " + int(_tX / 10000.0) / 100.0 + " MHz, "+int(_tY * 100) / 100.0 + " " + _parent.defaultUom;
            _label.x = mouseX;
            _label.y = mouseY;
            if(_bTracking)
            {
                var obj:Object = {dataX:Number(dataVals[0]), dataY:Number(dataVals[1])};
                _profile.addItem(obj);
            }
            /* the mouse moved over the chart, so grab the mouse coordaintes and redraw */
            _crosshairs = new Point(mouseX,mouseY);
            invalidateDisplayList();
        }
        
        private function removeCrosshairs(e:MouseEvent):void
        {
            _bTracking = false;
            _crosshairs = null;
            invalidateDisplayList();
        }
        
        private function draw_profile(g:Graphics,offset:Number):void
        {
            var data:Array = _profile.source.concat();
            var i:int;
            for(i = 0; i < _profile.length; i++)
            {
                data[i] = ObjectUtil.copy(_profile[i]);
                data[i].dataY += offset;
            }
            dataTransform.transformCache(data, "dataX", "x", "dataY", "y");
    
            for(i = 0; i < _profile.length; i++)
            {
                //data=[{dataX:profile[i].dataX,dataY:profile[i].dataY}];
                //data[0].dataY=data[0].dataY+offset;
                //dataTransform.transformCache(data,"dataX","x","dataY","y");
                if(i == 0)
                {
                    g.moveTo(data[i].x,data[i].y);
                    //g.drawRect(profile[i].x-4,profile[i].y-4,9,9);
                }
                else
                {
                    g.lineTo(data[i].x,data[i].y);
                }
            }
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            var g:Graphics = graphics;
            g.clear();
            g.moveTo(0, 0);
            g.lineStyle(0, 0, 0);
            g.beginFill(0, 0);
            g.drawRect(0, 0, unscaledWidth, unscaledHeight);
            g.endFill();
            dataTransform.transformCache(_profile.source, "dataX", "x", "dataY", "y");

             /* draw the crosshairs. Crosshairs are drawn where the mouse is, only when the mouse is over us, so we don't need to transform
            *    to data coordinates
            */
            if(_bSet)
            {
                if(_parent == null)
                {
                    _parent = this.parentApplication as DataLogViewer;
                }
                
                var panel:ProfilePanel = _parent.profilePanel;
                
                g.lineStyle(2, 0xA0A0A0, 0.25);
                draw_profile(g, 0);
                var offset:Number = Number(panel.major_entry.text);
                if(offset > 0)
                {
                    g.lineStyle(1,0xFF0000,1);
                    draw_profile(g,offset);
                }
                offset = Number(panel.minor_entry.text);
                if(offset > 0)
                {
                    g.lineStyle(1, 0x0000FF, 1);
                    draw_profile(g, offset);
                }
                  
                //g.lineStyle(1,0x220000,.8);
                //draw_profile(g,major_profile);
                /*if (major!=null)
                {
                    
                }
                if (minor!=null)
                {
                    
                }
                */
            }
            
            if(_crosshairs != null)
            {
                g.lineStyle(1, 0x005364, 0.5);
                g.moveTo(0,_crosshairs.y);
                g.lineTo(unscaledWidth,_crosshairs.y);
                g.moveTo(_crosshairs.x,0);
                g.lineTo(_crosshairs.x,unscaledHeight);
                _label.visible = true;
                _label.move(_crosshairs.x, _crosshairs.y - _label.measuredHeight);
                _label.setActualSize(_label.measuredWidth, _label.measuredHeight);
            }        
            else
            {
                _label.visible = false;
            }
        }
              
        override public function describeData(dimension:String, requiredFields:uint):Array
        {
            /* if no region is selected, we have no data */
            if(_bSet == false)
                return [];

            return[];
        } 
    }
}