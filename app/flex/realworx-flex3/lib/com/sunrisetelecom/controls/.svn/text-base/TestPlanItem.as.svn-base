package com.sunrisetelecom.controls
{	
	public dynamic class TestPlanItem extends Object
	{
		private var _dvc:DVChannel;
		private var _port:AnalyzerPort;
		private var _errorString:String = "";
		
        public function get errorString():String
        {
            return _errorString;
        }
        
        public function get frequency_str():String
        {
            if(_dvc == null) return "";

            return _dvc.freq_str;
        }
        public function set frequency_str(str:String):void
        {
            if(_dvc == null) return;
            
            _dvc.freq_str = str;
        }
		
		public function get modulation_name():String
		{
		    if(_dvc == null) return "";
		    
		    return _dvc.modulation_name;
		}
		public function set modulation_name(str:String):void
        {
            if(_dvc == null) return;
            
            _dvc.modulation_name = str;
        }
		
		public function get channel_name():String
		{
			if(_dvc == null) return "";
			
            return _dvc.name;
		}
		public function set channel_name(str:String):void
		{
		    if(_dvc == null) return;
		    
		    _dvc.name = str;
		}

		public function get channel():DVChannel
		{
			return _dvc;
		}
		public function set channel(ch:DVChannel):void
		{
			_dvc=ch;
		}
		
		public function get port():AnalyzerPort
		{
			return _port;
		}
		public function set port(port:AnalyzerPort):void
		{
			_port = port;
		}
		
		public function get port_name():String
		{
			if (_port == null)
			{
				return "NONE";
			}
			return _port.port_name;
		}

		
		public function get site_name():String
		{
			if(_port == null)
			{
				return "NONE";
			}
			return _port.site;
		}

		public function TestPlanItem(dvc:DVChannel, port:AnalyzerPort):void
		{
			_dvc = dvc;
			_port = port;
			
			this["ENM_ENABLE_FLAG"] = false;
			this["EVM_ENABLE_FLAG"] = false;
			this["DCP_ENABLE_FLAG"] = false;
			
			this["VIDEO_LVL_ENABLE_FLAG"] = false;
			this["VARATIO_ENABLE_FLAG"] = false;
			this["MEASURED_VIDEO_FREQ_ENABLE_FLAG"] = false;
			this["MEASURED_AUDIO_FREQ_ENABLE_FLAG"] = false;

			this["MER_ENABLE_FLAG"] = false;
			this["PRE_BER_ENABLE_FLAG"] = false;
			this["POST_BER_ENABLE_FLAG"] = false;

			super();
		}
		
		public function validate(measures:Array):Boolean
		{
			for(var i:int = 0; i < measures.length; i++)
			{
				var measure:Object = measures[i];
				//{MEAS: meas,LABEL: label,LOWER: lower, UPPER: upper, ANALOG: analog,POSITION: pos}

				if(measure.ANALOG == _dvc.is_analog) //Channel and Measure are of the same channel type
				{
					if(this[measure["ENABLE_FLAG"]] == true)
					{
						if(!measure["ENABLE_FLAG"].match(/BER/))
						{
							if(this[measure["MEAS"]] == null)
							{
								_errorString = "Nominal Required for " + measure.LABEL;
								return false;
							}
							var minor_label:String = measure["MEAS"] + "_MINOR";
							var major_label:String = measure["MEAS"] + "_MAJOR";				
							
							if(this[minor_label] == null)
							{
								_errorString = "Minor Field is Required for " + measure.LABEL;
								return false;
							} 
							if(this[major_label] == null)
							{
								_errorString = "Major Field is Required for " + measure.LABEL;
								return false;
							}
							
							var minor:Number = Number(this[minor_label]);
                            var major:Number = Number(this[major_label]);
							
							if(minor > major)
							{
								_errorString = "Minor must be less than Major for " + measure.LABEL;
								return false;
							}  
						}
					}
				}
			}
			return true;
		}

		
	}
}