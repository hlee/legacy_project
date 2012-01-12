package com.sunrisetelecom.controls
{
    import com.sunrisetelecom.avantron.SettingsObj;
	public interface IMeasWindow
	{
		function display_trace(values:Object):void;
		function reset_display_values():void;
		function update_settings(settings:SettingsObj):void;
	}
}