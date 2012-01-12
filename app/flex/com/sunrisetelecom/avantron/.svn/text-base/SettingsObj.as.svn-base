package com.sunrisetelecom.avantron
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import mx.collections.ArrayCollection;
    
    dynamic public class SettingsObj extends Object
    {
        public var mode:String;
      
        public function toLabelList():Array
        {
            var label_list:Array=new Array();
            for (var prop:String in this)
            {
                label_list.push(prop);
            }
            return label_list;
        }
        
        public function toString():String
        {
            var result:String;
            for(var prop:String in this)
            {
                result = prop + "=" + this[prop] + "| " + result;
            }
            return result;
        }
        
        public function importObj(obj:Object):void
        {
            for(var prop:String in obj)
            {
                this[prop] = obj[prop];
            }
        }
        
        public function generateCollection():ArrayCollection
        {
            var collection:ArrayCollection = new ArrayCollection();
            for (var k:String in this)
            {
                collection.addItem({name:k,value:this[k]});
            }
            return collection;
        }
        
        public function toByteArray():ByteArray
        {
            //[ "SA", "SS", "BAS", "DCP", "SM1", "SM2", "SM6", "SMn",
            //"HUM", "NI", "FR", "DM", "", "MONITORING", "TDMA", "QAM", "MONITORING", "",
            //"DIGITAL MONITORING", "ANALOG MONITORING"];
            var settingsBA:ByteArray=new ByteArray();
            settingsBA.endian=Endian.LITTLE_ENDIAN;
       
            if (mode == "SA")
            {
                settingsBA.writeShort(0);//Length of data
                settingsBA.writeByte(2);//Set Settings sub command
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(0);//Mode
                settingsBA.writeShort(0);// resv1 & resv2
                settingsBA.writeShort(0);//who cares about the external temp
                settingsBA.writeShort(parseInt(this["ATT"]));//Attenuation
                settingsBA.writeShort(parseInt(this["IF"]));//Internal Freq
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ"]));//Central Freq
                trace("CENTER_FREQ:" +parseFloat(this["CENTER_FREQ"]).toString());
                settingsBA.writeDouble(parseFloat(this["SPAN"]));//Span
                settingsBA.writeShort(parseInt(this["ZERO_SPAN"]));
                settingsBA.writeShort(parseInt(this["VIDEO_CHAN"]));//Video Channel
                settingsBA.writeShort(parseInt(this["AUDIO_CHAN"]));
                settingsBA.writeShort(parseInt(this["SWEEP"]));
                settingsBA.writeDouble(parseFloat(this["HORZ_TIME"]));

                settingsBA.writeDouble(parseFloat(this["RBW"]));
                settingsBA.writeDouble(parseFloat(this["VBW"]));
                settingsBA.writeShort(0);// resv3
                settingsBA.writeByte(parseInt(this["AVG_TYPE"]));
                settingsBA.writeByte(parseInt(this["V2_NOISE_MARKER"]));
                settingsBA.writeByte(parseInt(this["FM_HORZ_MARK"]));
                settingsBA.writeByte(0);// resv3
                settingsBA.writeShort(parseInt(this["VERT_SCALE"]));
                settingsBA.writeByte(parseInt(this["AUD_VOLUME"]));
                settingsBA.writeByte(parseInt(this["TRIGGER_TYPE"]));
                settingsBA.writeByte(parseInt(this["H1_DISP"]));
                settingsBA.writeByte(parseInt(this["H2_DISP"]));
                settingsBA.writeByte(parseInt(this["V1_DISP"]));
                settingsBA.writeByte(parseInt(this["V2_DISP"]));
                settingsBA.writeDouble(parseFloat(this["V1_POS"]));
                settingsBA.writeDouble(parseFloat(this["V2_POS"]));
                settingsBA.writeShort(parseInt(this["H1_POS"]));
                settingsBA.writeShort(parseInt(this["H2_POS"]));
            }
            else if (mode == "DCP")
            {
                settingsBA.writeShort(0);//Length of data
                settingsBA.writeByte(2);//Set Settings sub command
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(3);//Mode
                settingsBA.writeShort(0);// resv1 & resv2
                settingsBA.writeShort(parseInt(this["ATT"]));//Attenuation
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ"]));//Central Freq
                trace("CENTER_FREQ:" +parseFloat(this["CENTER_FREQ"]).toString());
                settingsBA.writeShort(parseInt(this["VIDEO_CHAN"]));//Video Channel
                settingsBA.writeShort(parseInt(this["AUDIO_CHAN"]));
                settingsBA.writeShort(parseInt(this["VERT_SCALE"]));
                settingsBA.writeShort(parseInt(this["AVG_TYPE"]));
                settingsBA.writeDouble(parseFloat(this["BWD"]));
            }
            else if (mode == "QAM")
            {
                settingsBA.writeShort(0);//Length of data
                settingsBA.writeByte(2);//Set Settings sub command
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(15);//Mode
                settingsBA.writeByte(103);//Version
                settingsBA.writeByte(parseInt(this["ST_TYPE"]));//Standard Type
                settingsBA.writeByte(parseInt(this["MOD_TYPE"]));//Modulation Type
                settingsBA.writeByte(parseInt(this["POLARITY"]));//POLARITY
                settingsBA.writeShort(parseInt(this["MER_THRESH"]));//Mer Threshold
                settingsBA.writeFloat(parseInt(this["PREBER_THRESH"]));//PRE BER Threshold
                settingsBA.writeFloat(parseInt(this["POSTBER_THRESH"]));//POST BER Threshold
                settingsBA.writeShort(parseInt(this["ATT"]));//Attenuation
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VIDEO_CHAN"]));//Video Channel
                settingsBA.writeByte(parseInt(this["CP_USAGE"]));//Channel Plan Usage
                settingsBA.writeByte(parseInt(this["NOISE_NEAR_NOISE"]));//Noise Near Noise
                settingsBA.writeInt(parseInt(this["IDEAL_SYMB_RATE"]));//Ideal Symbol Rate
                settingsBA.writeInt(parseInt(this["SES_THRESH"]));//SES Threshold
                settingsBA.writeByte(parseInt(this["DISPLAY_TYPE"]));//Display Type
                settingsBA.writeByte(parseInt(this["GRID_STATUS"]));//Grid Status
                settingsBA.writeByte(parseInt(this["TMPL_STATUS"]));//Template Status
                settingsBA.writeByte(parseInt(this["INTERLEAVE_I"]));//Interleave I
                settingsBA.writeByte(parseInt(this["INTERLEAVE_J"]));//Interleave J
                settingsBA.writeByte(parseInt(this["FILTER_TYPE"]));// Filter Type
                settingsBA.writeInt(parseInt(this["FILTER_SIZE"]));// Filter Size
                settingsBA.writeByte(parseInt(this["START_STAT"]));// Start Stat
                settingsBA.writeByte(parseInt(this["ZOOM_TYPE"]));//   Zoom Type
                settingsBA.writeByte(parseInt(this["FIRST_ZOOM"]));//  First Zoom
                settingsBA.writeByte(parseInt(this["SECOND_ZOOM"]));// Second Zoom
                settingsBA.writeInt(parseInt(this["HIGH_FILTER"]));//  High Filter
                settingsBA.writeInt(parseInt(this["Low_FILTER"]));//  Low Filter
            }
            else if ((mode == "SM1") || (mode == "SM2") || (mode == "SM6"))
            {
                settingsBA.writeShort(0);//Length of data
                settingsBA.writeByte(2);//Set Settings sub command
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(0);//resv
                settingsBA.writeByte(6);//Mode
                settingsBA.writeInt(0);//Resv and temp
                settingsBA.writeShort(parseInt(this["ATT"]));//Attenuation
                settingsBA.writeShort(parseInt(this["IF"]));//Internal Freq
                settingsBA.writeDouble(0);//8 bytes reserved
                settingsBA.writeByte(parseInt(this["CARRIER_NBR"]));//Carrier Number
                settingsBA.writeByte(parseInt(this["NBR_MEAS_CAR"]));//Number Meas Cearrier
                settingsBA.writeShort(parseInt(this["VERT_SCALE"]));//Vert Scale

                settingsBA.writeByte(parseInt(this["MEAS_TYPE_1"]));//Meas Type
                settingsBA.writeByte(parseInt(this["ACT_CARR_1"]));//Active Carrier
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ_1"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VID_SEL_1"]));//Central Freq
                settingsBA.writeShort(parseInt(this["AUD_SEL_1"]));//Central Freq

                settingsBA.writeByte(parseInt(this["MEAS_TYPE_2"]));//Meas Type
                settingsBA.writeByte(parseInt(this["ACT_CARR_2"]));//Active Carrier
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ_2"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VID_SEL_2"]));//Central Freq
                settingsBA.writeShort(parseInt(this["AUD_SEL_2"]));//Central Freq

                settingsBA.writeByte(parseInt(this["MEAS_TYPE_3"]));//Meas Type
                settingsBA.writeByte(parseInt(this["ACT_CARR_3"]));//Active Carrier
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ_3"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VID_SEL_3"]));//Central Freq
                settingsBA.writeShort(parseInt(this["AUD_SEL_3"]));//Central Freq

                settingsBA.writeByte(parseInt(this["MEAS_TYPE_4"]));//Meas Type
                settingsBA.writeByte(parseInt(this["ACT_CARR_4"]));//Active Carrier
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ_4"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VID_SEL_4"]));//Central Freq
                settingsBA.writeShort(parseInt(this["AUD_SEL_4"]));//Central Freq

                settingsBA.writeByte(parseInt(this["MEAS_TYPE_5"]));//Meas Type
                settingsBA.writeByte(parseInt(this["ACT_CARR_5"]));//Active Carrier
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ_5"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VID_SEL_5"]));//Central Freq
                settingsBA.writeShort(parseInt(this["AUD_SEL_5"]));//Central Freq

                settingsBA.writeByte(parseInt(this["MEAS_TYPE_6"]));//Meas Type
                settingsBA.writeByte(parseInt(this["ACT_CARR_6"]));//Active Carrier
                settingsBA.writeDouble(parseFloat(this["CENTER_FREQ_6"]));//Central Freq
                settingsBA.writeShort(parseInt(this["VID_SEL_6"]));//Central Freq
                settingsBA.writeShort(parseInt(this["AUD_SEL_6"]));//Central Freq
            }
            settingsBA.position=0;
            return settingsBA;
        }
        
        public function buildFromByteArray(packetBA:ByteArray):void
        {
            if (mode == "SA")
            {
                packetBA.position+=4; //4 Skip over 2 reserves and external temp.
                this["ATT"]= packetBA.readUnsignedShort();
                this["IF"]=packetBA.readShort();
                    
                this["CENTER_FREQ"]= String(packetBA.readDouble());
                this["SPAN"] =String(packetBA.readDouble());
                this["ZERO_SPAN"]=String(packetBA.readShort());
                this["VIDEO_CHAN"]=String(packetBA.readShort());
                this["AUDIO_CHAN"]=String(packetBA.readShort());
                this["SWEEP"]=String(packetBA.readShort());
           
                this["HORZ_TIME"] = packetBA.readDouble();
                trace("RBW Pos:" + packetBA.position);
                this["RBW"] = String(packetBA.readDouble());
                this["VBW"] = String(packetBA.readDouble());
                packetBA.position+=2;
                this["AVG_TYPE"] = packetBA.readByte();
                this["V2_NOISE_MARKER"] = packetBA.readByte();
                this["FM_HORZ_MARKER"] = packetBA.readByte();
                packetBA.position+=1;
                this["VERT_SCALE"] = packetBA.readUnsignedShort();
                this["AUD_VOL"] = packetBA.readByte();
                this["TRIGGER_TYPE"] = packetBA.readByte();
                this["H1_DISP"] = packetBA.readByte();
                this["H2_DISP"] = packetBA.readByte();
                this["V1_DISP"] = packetBA.readByte();
                this["V2_DISP"] = packetBA.readByte();
                this["V1_POS"] = packetBA.readDouble();
                this["V2_POS"] = packetBA.readDouble();
                this["H1_POS"] = packetBA.readUnsignedShort();
                this["H2_POS"] = packetBA.readUnsignedShort();
            }
            else if (mode == "DCP")
            {
                packetBA.position+=2; // Skip over 2 reserve bytes
                this["ATT"]= packetBA.readUnsignedShort();
                this["CENTER_FREQ"]= String(packetBA.readDouble());
                this["VIDEO_CHAN"]= packetBA.readUnsignedShort();
                this["AUDIO_CHAN"]= packetBA.readUnsignedShort();
                this["VERT_SCALE"]= packetBA.readUnsignedShort();
                this["AVG_TYPE"]= packetBA.readUnsignedShort();
                this["BWD"] =String(packetBA.readDouble());
            }
            else if (mode == "QAM")
            {
                packetBA.position+=1;//Skip the Version
                this["ST_TYPE"] = packetBA.readByte();//Standard Type
                this["MOD_TYPE"] = packetBA.readByte();//Modulation Type
                this["POLARITY"] = packetBA.readByte();//POLARITY
                this["MER_THRESH"] = packetBA.readUnsignedShort();//Mer Threshold
                this["PREBER_THRESH"] = packetBA.readFloat();//PRE BER Threshold
                this["POSTBER_THRESH"] = packetBA.readFloat();//POST BER Threshold
                this["ATT"] = packetBA.readShort();//Attenuation
                this["CENTER_FREQ"]=packetBA.readDouble();//Central Freq
                this["VIDEO_CHAN"] = packetBA.readShort();//Video Channel
                this["CP_USAGE"] = packetBA.readByte();//Channel Plan Usage
                this["NOISE_NEAR_NOISE"] = packetBA.readByte();//Noise Near Noise
                this["IDEAL_SYMB_RATE"] = packetBA.readInt();//Ideal Symbol Rate
                this["SES_THRESH"] = packetBA.readInt();//SES Threshold
                this["DISPLAY_TYPE"] = packetBA.readByte();//Display Type
                this["GRID_STATUS"] = packetBA.readByte();//Grid Status
                this["TMPL_STATUS"] = packetBA.readByte();//Template Status
                this["INTERLEAVE_I"] = packetBA.readByte();//Interleave I
                this["INTERLEAVE_J"] = packetBA.readByte();//Interleave J
                this["FILTER_TYPE"] = packetBA.readByte();// Filter Type
                this["FILTER_SIZE"] = packetBA.readInt();// Filter Size
                this["START_STAT"] = packetBA.readByte();// Start Stat
                this["ZOOM_TYPE"] = packetBA.readByte();//   Zoom Type
                this["FIRST_ZOOM"] = packetBA.readByte();//  First Zoom
                this["SECOND_ZOOM"] = packetBA.readByte();// Second Zoom
                this["HIGH_FILTER"] = packetBA.readInt();//  High Filter
                this["Low_FILTER"] = packetBA.readInt();//  Low Filter
            }
            else if ((mode == "SM1") || (mode == "SM2") || (mode == "SM6"))
            {
                packetBA.position+=4;//Skip reserved and external temperature
                this["ATT"] = packetBA.readShort();//Attenuation
                this["IF"] = packetBA.readShort();//Internal Freq
                packetBA.readDouble();//8 bytes reserved
                this["CARRIER_NBR"] = packetBA.readByte();//Carrier Number
                this["NBR_MEAS_CAR"] = packetBA.readByte();//Number Meas Cearrier
                this["VERT_SCALE"] = packetBA.readShort();//Vert Scale

                this["MEAS_TYPE_1"] = packetBA.readByte();//Meas Type
                this["ACT_CARR_1"] = packetBA.readByte();//Active Carrier
                this["CENTER_FREQ_1"]=packetBA.readDouble();//Central Freq
                this["VID_SEL_1"]=packetBA.readShort();//Central Freq
                this["AUD_SEL_1"]=packetBA.readShort();//Central Freq

                this["MEAS_TYPE_2"] = packetBA.readByte();//Meas Type
                this["ACT_CARR_2"] = packetBA.readByte();//Active Carrier
                this["CENTER_FREQ_2"]=packetBA.readDouble();//Central Freq
                this["VID_SEL_2"]=packetBA.readShort();//Central Freq
                this["AUD_SEL_2"]=packetBA.readShort();//Central Freq

                this["MEAS_TYPE_3"] = packetBA.readByte();//Meas Type
                this["ACT_CARR_3"] = packetBA.readByte();//Active Carrier
                this["CENTER_FREQ_3"]=packetBA.readDouble();//Central Freq
                this["VID_SEL_3"]=packetBA.readShort();//Central Freq
                this["AUD_SEL_3"]=packetBA.readShort();//Central Freq

                this["MEAS_TYPE_4"] = packetBA.readByte();//Meas Type
                this["ACT_CARR_4"] = packetBA.readByte();//Active Carrier
                this["CENTER_FREQ_4"]=packetBA.readDouble();//Central Freq
                this["VID_SEL_4"]=packetBA.readShort();//Central Freq
                this["AUD_SEL_4"]=packetBA.readShort();//Central Freq

                this["MEAS_TYPE_5"] = packetBA.readByte();//Meas Type
                this["ACT_CARR_5"] = packetBA.readByte();//Active Carrier
                this["CENTER_FREQ_5"]=packetBA.readDouble();//Central Freq
                this["VID_SEL_5"]=packetBA.readShort();//Central Freq
                this["AUD_SEL_5"]=packetBA.readShort();//Central Freq

                this["MEAS_TYPE_6"] = packetBA.readByte();//Meas Type
                this["ACT_CARR_6"] = packetBA.readByte();//Active Carrier
                this["CENTER_FREQ_6"]=packetBA.readDouble();//Central Freq
                this["VID_SEL_6"]=packetBA.readShort();//Central Freq
                this["AUD_SEL_6"]=packetBA.readShort();//Central Freq
            }
        }
    }
}
