package com.sunrisetelecom.controls
{
	public class DVChannel
	{
		public static const DIGITAL:int = 1;
		public static const ANALOG:int = 0;

		public static const SYMBOL_RATE_DIVISOR:Number = 1000000.0;
		public static const FREQ_DIVISOR:Number = 1000000.0;
		
		public static const annexes:XML=
		<annexes>
		  <annex tag="0" name="Annex A"/>
		  <annex tag="1" name="Annex B"/>
		  <annex tag="2" name="Annex C"/>
		</annexes>;
		
		public static const polarities:XML=
		<polarities>
		  <polarity tag="0" name="Normal"/>
		  <polarity tag="1" name="Inverse"/>
		  <polarity tag="2" name="Auto"/>
		</polarities>;
		
		public static const modulations:XML=
		<modulations>
		  <modulation tag="0" name="QPSK" chan_type="Digital" symbol_rate="5056900"/>
  		  <modulation tag="1" name="QAM64" chan_type="Digital" symbol_rate="5056900"/>
  		  <modulation tag="2" name="QAM16" chan_type="Digital" symbol_rate="5056900"/>
          <modulation tag="3" name="QAM256" chan_type="Digital" symbol_rate="5360500"/> 
          <modulation tag="9" name="CW" chan_type="Digital" symbol_rate="0"/>
          <modulation tag="100" name="NTSC" chan_type="Analog"/> 
          <modulation tag="101" name="PAL_B" chan_type="Analog"/> 
          <modulation tag="102" name="PAL_G" chan_type="Analog"/> 
          <modulation tag="103" name="PAL_I" chan_type="Analog"/> 
          <modulation tag="104" name="PAL_M" chan_type="Analog"/> 
          <modulation tag="105" name="PAL_N" chan_type="Analog"/> 
          <modulation tag="106" name="SECAM_B" chan_type="Analog"/> 
          <modulation tag="107" name="SECAM_G" chan_type="Analog"/> 
          <modulation tag="108" name="SECAM_K" chan_type="Analog"/> 
        </modulations>;
        
        private var _systemFile:String;
        private var _modulation:int; 
        private var _frequency:Number; 
		private var _symbolRate:Number;
		private var _bandwidth:Number;
        private var _name:String;
		private var _number:String;
		private var _audio1_offset:Number;
		private var _audio2_offset:Number;
		private var _annex:int = 1;
		private var _polarity:int = 0;
		
		public function get system_file():String
		{
		    return _systemFile;
		}
		public function set system_file(s:String):void
		{
		    _systemFile = s;
		}

        public function get name():String
        {
            return _name;
        }
        public function set name(n:String):void
        {
            _name = n;   
        }

        public function get number():String
        {
            return _number;
        }
        public function set number(n:String):void
        {
            _number = n;
        }
		
		public function get annex():int 
		{
			return _annex;
		}
		public function set annex(a:int):void
		{
		    if(!isNaN(a) && a >=0 && a <= 2) _annex = a;
		}
		public function get annex_name():String
        {
            if (is_analog)
            {
                return "N/A";   
            }
            else
            {
                return annexes.annex.(@tag==_annex)[0].@name;
            }
        }
        public function set polarity_name(name:String):void
        {
            if(name != "")
            {
                _polarity = polarities.polarity.(@name==name)[0].@tag;
            }
        }
		
		public function get polarity():int
		{
		    return _polarity;
		}
		public function set polarity(p:int):void
		{
		    if(!isNaN(p) && p >=0 && p <= 2) _polarity = p;
		}
		public function get polarity_name():String
		{
			if(is_analog)
			{
				return "N/A";
			}
			else
			{
				return polarities.polarity.(@tag==_polarity)[0].@name;
			}
		}
		public function set annex_name(name:String):void
		{
			if(name != "")
			{
				_annex = annexes.annex.(@name==name)[0].@tag;
			}
		}
		
		public static function modNameByNumber(modnbr:Number):String
		{
			return modulations.modulation.(@tag==modnbr.toString())[0].@name;
		}
		
		//Constructor
		public function DVChannel(sf:String,number:String,name:String,
		   frequency:Number,modulation:String,bandwidth:Number,
		   audio1_offset:Number=NaN, audio2_offset:Number = NaN)
		{
			_modulation=Number(modulations.modulation.(@name==modulation)[0].@tag);
			_frequency=frequency;
			this._systemFile=sf;
			this.name=name;
			this.number=number;
			this._bandwidth=bandwidth;
			this._audio1_offset=audio1_offset;
			this._audio2_offset=audio2_offset;
			
			

			
			if (is_analog)
			{
				if (isNaN(audio1_offset))
				{
					throw new Error("Audio Offset required for analog channels");
				}
			}
			else
			{
				_symbolRate = lookup_default_symbol_rate(_modulation);
				//if (!isNaN(audio1_offset))
				//{
					//throw new Error("Audio Offset not allowed for digital channels");
				//}
			}
		}
		// XML Lookups
		public static function lookup_default_symbol_rate(modulation_tag:Number):Number
		{
			var xlist:XMLList;
			xlist = modulations.modulation.(@tag == modulation_tag)
			if (xlist.length() == 0)
			{
				throw new Error("Modulation Tag Not Found");
			}
			if (String(xlist[0].@chan_type) == "Digital")
			{
				return Number(modulations.modulation.(@tag == modulation_tag)[0].@symbol_rate);
			}
            
            throw new Error("No Symbol Rate for analog channels");
		}
		
		public function get label():String
		{
			return _systemFile + ":" + name;
		}
		
		public function get symbol_rate():Number
		{
			if(!is_analog)
			{
			   return _symbolRate;
			}
			return NaN;
		}
		public function set symbol_rate(sr:Number):void
		{
			if(!is_analog)
			{
				_symbolRate = sr;
			}
		}
		public function get symbol_rate_str():String
		{
			if(is_analog)
			{
                return "N/A";
			}
			else
			{
                return (_symbolRate / SYMBOL_RATE_DIVISOR).toString();
			}
		}
		public function get symbol_rate_entry():Number
		{
			return (_symbolRate / SYMBOL_RATE_DIVISOR);
		}
		public function set symbol_rate_entry(entry:Number):void
		{
			_symbolRate = entry * SYMBOL_RATE_DIVISOR;
		}
		public function get data():String
		{
			return name;
		}
		public function get modulation():Number
		{
			return _modulation;
		}
		public function set modulation(modulation:Number):void
		{
			_modulation=modulation; 
			if(!is_analog)
			{
				_symbolRate = lookup_default_symbol_rate(modulation);
			}
		}
		public function get modulation_name():String
		{
			return String(modulations.modulation.(@tag == String(_modulation))[0].@name);
		}
		public function set modulation_name(mod_str:String):void
		{
			if(mod_str == "")
			{
				return;
			}
			var tmp_modulation:int = int(modulations.modulation.(@name==String(mod_str))[0].@tag);
			modulation = tmp_modulation;
		}
		public function get frequency():Number
		{
			return _frequency;
		}
		public function set frequency(f:Number):void
		{
			_frequency = f;
		}

		public function set freq_str(f:String):void
		{
			_frequency = parseFloat(f)*FREQ_DIVISOR;
		}
		public function get freq_str():String
		{
			
			return (_frequency / FREQ_DIVISOR).toFixed(4); 
		}
		public function get is_analog():Boolean
		{
			if(String(modulations.modulation.(@tag == String(_modulation))[0].@chan_type) == "Analog")
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		public function get bandwidth():Number
		{
			return _bandwidth;
		}
		public function set bandwidth(f:Number):void
		{
			_bandwidth = f;
		}
		public function get bandwidth_str():String
		{
			return (_bandwidth / FREQ_DIVISOR).toFixed(2) ;
		}
		public function get bandwidth_entry():Number
		{
			return _bandwidth / FREQ_DIVISOR;
		}
		public function set bandwidth_entry(f:Number):void
		{
			_bandwidth=f*FREQ_DIVISOR;
		}
		public function get audio1_offset():Number
		{
			return _audio1_offset;
		}
		public function set audio1_offset(f:Number):void
		{
			_audio1_offset = f;
		}
		public function set audio2_offset(f:Number):void
		{
			_audio2_offset = f;
		}
		public function set audio1_offset_str(f:String):void
		{
			_audio1_offset=parseFloat(f)*FREQ_DIVISOR;
		}

		public function set audio2_offset_str(f:String):void
		{
			_audio2_offset=parseFloat(f)*FREQ_DIVISOR;
		}
		public function get audio1_offset_str():String
		{
			if(!is_analog)
			{
				return "N/A";
			}
			else
			{
				if(isNaN(_audio1_offset))
				{
					_audio1_offset = 0;
				}
				return (_audio1_offset / 1000000.0).toFixed(4);
			}
		}
		
		public function get audio2_offset():Number
		{
			return _audio2_offset;
		}
		
		public function get audio2_offset_str():String
		{
			if(!is_analog)
			{
				return "N/A";
			}
			else
			{
				if(isNaN(_audio2_offset))
				{
					_audio1_offset = 0;
				}
				return (_audio2_offset / 1000000.0).toFixed(4);
			}
		}
	}
}
