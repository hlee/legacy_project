package com.sunrisetelecom.controls
{
	public class ExpFormat 
	{
		public function ExpFormat()
		{
			   
		}
		
		public static function format(value:Object):String
		{
			var val:Number = value as Number;
			if((value == null) || (val < 1E-13)) 
			{
				val = 1E-12;
			}
			var result:String = "1x10^" + Math.round(Math.log(val) / Math.log(10)).toString();
			return result;
		}
	}
}