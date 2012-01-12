package com.sunrisetelecom.avantron {
   import flash.system.System;
   import flash.net.NetConnection;
   import flash.events.*;
   import mx.utils.ArrayUtil;
   import flash.errors.IOError;
   import flash.net.Socket;
   import flash.utils.*;
   import flash.external.ExternalInterface;
   import flash.system.Security;
   import mx.controls.Alert;
   import mx.core.Application;
   import mx.utils.URLUtil;
   import flash.system.SecurityDomain;
   import mx.rpc.http.HTTPService;
   import mx.collections.ArrayCollection;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.events.FaultEvent;

public class Protocol extends Object {
      private var callback:Function;
      private static const AS0:int = 49;
      private static const AS1:int = 48;
      private static const HD0:int = 1;
      private static const HD1:int = 2;
      private static const HF0:int = 3;
      private static const HF1:int = 4;
      private static const MAX_SHORT:uint = 65535;
      private static const INCR_DYN_RANGE:Number = 70/1024;
      private var m_default_node_number:String = '001';
      private var m_instr_address:String = "127.0.0.1"
      private var m_instr_port:Number = 3015; // This is the port for the analyzer.
      private var m_socket:Socket = new Socket();
      private var m_msg_queue:Queue=new Queue();
      private var m_response_queue:Queue=new Queue();
      private var m_msg_timer:Timer=new Timer(400);
      private var m_node_count:ArrayCollection=new ArrayCollection();
      private var m_trace_cycle:int=3;
      private var m_trace_count:int=0;

     
      private var m_hmid:String="01";
      [Bindable]
      private var m_modes:Array = [ "SA", "SS", "BAS", "DCP", "SM1", "SM2", "SM6", "SMn",
      "HUM", "NI", "FR", "DM", "", "MONITORING", "TDMA", "QAM", "MONITORING", "",
      "DIGITAL MONITORING", "ANALOG MONITORING"];
         
      private var m_crc_table:Array = [
         0x0000,  0x1021,  0x2042,  0x3063,  0x4084,  0x50A5,  0x60C6,  0x70E7,
         0x8108,  0x9129,  0xA14A,  0xB16B,  0xC18C,  0xD1AD,  0xE1CE,  0xF1EF,
         0x1231,  0x0210,  0x3273,  0x2252,  0x52B5,  0x4294,  0x72F7,  0x62D6,
         0x9339,  0x8318,  0xB37B,  0xA35A,  0xD3BD,  0xC39C,  0xF3FF,  0xE3DE,
         0x2462,  0x3443,  0x420,   0x1401,  0x64E6,  0x74C7,  0x44A4,  0x5485,
         0xA56A,  0xB54B,  0x8528,  0x9509,  0xE5EE,  0xF5CF,  0xC5AC,  0xD58D,
         0x3653,  0x2672,  0x1611,  0x0630,  0x76D7,  0x66F6,  0x5695,  0x46B4,
         0xB75B,  0xA77A,  0x9719,  0x8738,  0xF7DF,  0xE7FE,  0xD79D,  0xC7BC,
         0x48C4,  0x58E5,  0x6886,  0x78A7,  0x0840,  0x1861,  0x2802,  0x3823,
         0xC9CC,  0xD9ED,  0xE98E,  0xF9AF,  0x8948,  0x9969,  0xA90A,  0xB92B,
         0x5AF5,  0x4AD4,  0x7AB7,  0x6A96,  0x1A71,  0x0A50,  0x3A33,  0x2A12,
         0xDBFD,  0xCBDC,  0xFBBF,  0xEB9E,  0x9B79,  0x8B58,  0xBB3B,  0xAB1A,
         0x6CA6,  0x7C87,  0x4CE4,  0x5CC5,  0x2C22,  0x3C03,  0x0C60,  0x1C41,
         0xEDAE,  0xFD8F,  0xCDEC,  0xDDCD,  0xAD2A,  0xBD0B,  0x8D68,  0x9D49,
         0x7E97,  0x6EB6,  0x5ED5,  0x4EF4,  0x3E13,  0x2E32,  0x1E51,  0x0E70,
         0xFF9F,  0xEFBE,  0xDFDD,  0xCFFC,  0xBF1B,  0xAF3A,  0x9F59,  0x8F78,
         0x9188,  0x81A9,  0xB1CA,  0xA1EB,  0xD10C,  0xC12D,  0xF14E,  0xE16F,
         0x1080,  0x00A1,  0x30C2,  0x20E3,  0x5004,  0x4025,  0x7046,  0x6067,
         0x83B9,  0x9398,  0xA3FB,  0xB3DA,  0xC33D,  0xD31C,  0xE37F,  0xF35E,
         0x02B1,  0x1290,  0x22F3,  0x32D2,  0x4235,  0x5214,  0x6277,  0x7256,
         0xB5EA,  0xA5CB,  0x95A8,  0x8589,  0xF56E,  0xE54F,  0xD52C,  0xC50D,
         0x34E2,  0x24C3,  0x14A0,  0x0481,  0x7466,  0x6447,  0x5424,  0x4405,
         0xA7DB,  0xB7FA,  0x8799,  0x97B8,  0xE75F,  0xF77E,  0xC71D,  0xD73C,
         0x26D3,  0x36F2,  0x0691,  0x16B0,  0x6657,  0x7676,  0x4615,  0x5634,
         0xD94C,  0xC96D,  0xF90E,  0xE92F,  0x99C8,  0x89E9,  0xB98A,  0xA9AB,
         0x5844,  0x4865,  0x7806,  0x6827,  0x18C0,  0x08E1,  0x3882,  0x28A3,
         0xCB7D,  0xDB5C,  0xEB3F,  0xFB1E,  0x8BF9,  0x9BD8,  0xABBB,  0xBB9A,
         0x4A75,  0x5A54,  0x6A37,  0x7A16,  0x0AF1,  0x1AD0,  0x2AB3,  0x3A92,
         0xFD2E,  0xED0F,  0xDD6C,  0xCD4D,  0xBDAA,  0xAD8B,  0x9DE8,  0x8DC9,
         0x7C26,  0x6C07,  0x5C64,  0x4C45,  0x3CA2,  0x2C83,  0x1CE0,  0x0CC1,
         0xEF1F,  0xFF3E,  0xCF5D,  0xDF7C,  0xAF9B,  0xBFBA,  0x8FD9,  0x9FF8,
         0x6E17,  0x7E36,  0x4E55,  0x5E74,  0x2E93,  0x3EB2,  0x0ED1,  0x1EF0
      ]   

      //////////////////////
      // Protocol - Constructor
      // resp_callback - function to be called when we get a message from the instr_host
      // instr_host - Either an instrument or a realview host in the form of an addressable domain name or ip.
      //////////////////////////
      public function Protocol(resp_callback:Function,instr_address:String,instr_port:int):void {
         callback=resp_callback;
         m_socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
         m_msg_timer.addEventListener("timer",dequeueTimerHandler);
         m_msg_timer.start();
         m_instr_address=instr_address;
         m_instr_port=instr_port;
      }

      //////////////////////
      // ioErrorHandler - Catches the IO_ERROR for the instr_host socket.
      //////////////////////////
      private function ioErrorHandler(event:IOErrorEvent):void
      {
         Alert.show("Unable to connect to " + m_instr_address + ". Please verify status and reload page");
      }

      //////////////////////
      // set_hmid 
      // Sets the hmid that will be logged into for hmid.  
      // Maybe we should move this to the constructor.
      //////////////////////////
      public function set_hmid(hmid:String):void
      {
         m_hmid=hmid;
      }
        
      //////////////////////
      // set_trace_cycle
      // Set the trace cycle for how quickly the traces update.
      /////////////////////
      public function set_trace_cycle(trace_cycle:int):void
      { 
        m_trace_cycle=trace_cycle;
      }

      //////////////////////
      // parsePacketData
      // Parses the packet data.
      //////////////////////////
      public function parsePacketData(packet:ByteArray):void {  
         packet.endian=Endian.LITTLE_ENDIAN;
         var commandObj:Object = new Object();
         var dataPoints:Array;
         var i:int;

         //TOMMIE the state machine is embedded here.  It needs to be broken out.
         var msg_type:int=packet[6]*256+packet[7]; //We want this in big endian format. So we did not use standard functions.
         var response_type:String;
         trace("RECVING :" +msg_type);
         //msg_type is in the format of a short. 
         //The short is actually two bytes that refer to the ascii characters that make up the message type.
         //IMHO I compromised code readibility for performance here.
         switch(msg_type) {
            case 12337: //01 ACK
            response_type=String(m_response_queue.get());
            trace("Ack:"+response_type);
               switch (response_type) {
                  case "logon":
                  case "selectRPTP":
                  case "logoff":
                  case "newMode" : 
                  case "setSettings" : 
                     callback(response_type,"ack");
                     break;
                  default:
                     break;
               }
               
               
               break;
               
            case 12338://02 NAK
            response_type=String(m_response_queue.get());
            trace("Nak:"+response_type);
            
                callback(response_type, "nak",packet[15]);
               break;
         
            case 12848://20 GENERAL COMMANDS
               general_response(packet);
               break;
            case  12341: //05 IMAGE TRACE
               //IMAGE SPEC
               var image:Array = [];
               var pct_image:ByteArray = new ByteArray();
               var val:int;
               m_trace_count++;
               if (m_trace_count < m_trace_cycle)
               {
                 break;
               }
               else
               {
                 m_trace_count=0;
               }
               //var debug_min_index:int=0;
               //var debug_max_index:int=0;
               for ( i=0; i<125 ; i++ ) {
                  image[4*i] = (( packet[5*i+16] << 2) | (packet[5*i+17] >> 6)) *INCR_DYN_RANGE ;
                  image[4*i+1] = (((packet[5*i+17] & 0x3F)<< 4) | (packet[5*i+18] >> 4)) *INCR_DYN_RANGE;
                  image[4*i+2] = (( (packet[5*i+18] & 0xF)<< 6) | (packet[5*i+19] >> 2)) *INCR_DYN_RANGE ;
                  image[4*i+3] = (((packet[5*i+19] & 0x3) << 8)| (packet[5*i+20] >> 0))*INCR_DYN_RANGE;
                  //if (image[debug_max_index] < image[i]) { debug_max_index=i; }
                  //if (image[debug_min_index] > image[i]) { debug_min_index=i; }
                  pct_image.writeUnsignedInt(image[4*i]*10/70)
                  pct_image.writeUnsignedInt(image[4*i+1]*10/70)
                  pct_image.writeUnsignedInt(image[4*i+2]*10/70)
                  pct_image.writeUnsignedInt(image[4*i+3]*10/70)
                  pct_image.writeUnsignedInt(image[4*i+4]*10/70)
                  
                  
               }
               trace("Memory:" + System.totalMemory );
               //trace("Memory:" + System.totalMemory + "," + pct_image[debug_max_index] + "," + image[debug_max_index]);
               //trace("MIN Memory:" + System.totalMemory + "," + pct_image[debug_min_index] + "," + image[debug_min_index]);
               callback("trigger","response",{image:image,pct_image:pct_image});

               break;
            case  14384: //80 SWITCH COMMAND
            packet.position=17;
              switch_response(packet);
              break;
           
            default:
               //addText("received unknown msg");
               break;
         }

      }
      ////////////////////
      // general_response
      // Parses the MSG_TYPE=20 messages from the avantron protocol.
      // packet - The raw packet data in the socket message
      //////////////
      private function general_response(packet:ByteArray):void
      {
         var i:int;
         var msgLen:int= (packet[12]-48)*100+(packet[13]-48)*10 + packet[14] -48;
         var tmpBA:ByteArray = new ByteArray();
         tmpBA.endian=Endian.LITTLE_ENDIAN;

         var tmpObj:Object = new Object();
         var obj:Object=new Object();
            
         switch( packet[17] ){
            case 12:
               packet.position=19;
               var sysType:String=packet.readUTFBytes(20);
               callback("getServerInfo","response",sysType);
               break;
            case 04:
               packet.position=19;
               obj["HW_FW_VER"]=packet.readUTFBytes(16);
               obj["SA_VER"]=packet.readUnsignedShort();
               obj["SYS_SWP_VER"]=packet.readUnsignedShort();
               obj["BIDIR_VER"]=packet.readUnsignedShort();
               obj["DCP_VER"]=packet.readUnsignedShort();
               obj["FREQ_CNT_VER"]=packet.readUnsignedShort();
               obj["TV_CHAN_VER"]=packet.readUnsignedShort();
               obj["MULTI_CARR_VER"]=packet.readUnsignedShort();
               obj["AUTOTEST_VER"]=packet.readUnsignedShort();
               obj["HUM_VER"]=packet.readUnsignedShort();
               callback("HwVER","response",obj);
               break;
            case 07:
               packet.position=19;
               obj["SYSTEM_TYPE"]=packet.readUTFBytes(20);
               obj["SYSTEM_SN"]=packet.readUTFBytes(20);
               obj["CAL_DATE"]=packet.readUTFBytes(20);
               callback("SYSINFO","response",anl_list);
               break;
            case 16:
               packet.position=19;
               break;
            case 14:
               packet.position=19;
               var option_value:int=packet.readByte();
               var txt_msg:String=packet.readUTFBytes(packet.bytesAvailable);
              // Alert.show("MSG"+txt_msg);
               //settings.hwType=packet.readUTFBytes(20);
               break;
            case 17:
               packet.position=19;
               var success:int=packet.readByte();
               

            case 20:
               //addText("recvd info " + packet[17]);
               //addText("length " + msgLen);
               packet.position=19
               tmpBA.writeBytes(packet,19,packet.length-19);
               var obj_count:int=packet.readUnsignedShort()
               var idx:int;
               var anl_list:Array=[];
               for(idx=0;idx<obj_count;idx++)
               {
         
                  var m_hmid:uint= packet.readUnsignedByte();
                  var avail:uint=packet.readUnsignedByte()
                  var name:String=packet.readUTFBytes(20);
                    if (avail != 0)
                    {
                       anl_list.push({label: name, data: m_hmid});
                    }
                }
                callback("listHM","response",anl_list);
                break;
             case 21:
                //addText("received nodes");
                packet.position=19
                var start_node:int=packet.readUnsignedShort();
                var alphaorder:int=packet.readUnsignedByte();
                var node_list:Array=[];
                var raw_node_list:Array=[]
                var nodeCount:int=packet.readUnsignedShort()
                //raw_node_list=packet.toString().split('\0000');
                for (i=0;i<nodeCount;i++) {
                   var pos:int=packet.readUnsignedShort();
                   var end_idx:int=packet.toString().indexOf("\u0000",packet.position);
                   var name_len:int=end_idx-packet.position;
                   var node_name:String=packet.readUTFBytes(name_len);
		   packet.readUTFBytes(12-name_len);
                   //packet.position=end_idx+1;
                   node_list[pos]=node_name;
		   trace("Pos:"+pos + "Node Name:"+node_name);
          
                };
                callback("listNodes","response",{node_list: node_list, start_node: start_node, node_count: nodeCount});
                break;
             case 1:
                var x:int; //garbage var
                var result:SettingsObj;
                tmpBA.writeBytes(packet);
                tmpBA.position=20;
                var mode:int=tmpBA.readByte();
                var smode:String = m_modes[mode];
                result=parse_settings(smode,tmpBA);
                result.MODE=mode;
                callback("getSettings","response",result);
                break;
                     
             default:
                trace(packet.toString());
                break;
          }
      }
      private function parse_settings(mode:String,packetBA:ByteArray):SettingsObj
      {
         var result:SettingsObj = new SettingsObj();
         result.mode=mode;
         result.buildFromByteArray(packetBA);
         return result;
        
      }
      ////////////////////
      // switch_response
      // Parses the MSG_TYPE=80 messages from the avantron protocol.
      // packet - The raw packet data in the socket message
      //////////////
      private function switch_response(packet:ByteArray):void
      {
        var swt_submsg:int;
        var rptpList:Array=new Array();
              Alert.show("SWITCH RESPINSE");
        swt_submsg=packet.readUnsignedShort();
        switch(swt_submsg){
	  case 32769:
            var rptp_selected:int=packet.readUnsignedShort();
	    Alert.show("RPTP"+rptp_selected);
	  break;
          case 32777 :
            var rptp_count:int=packet.readUnsignedShort();
            if (rptp_count > 256)
            {
               Alert.show("Unable to pull list of ports.");
               break;
            }
            //TODO handle error code
            for (var i:int=0;i<rptp_count;i++)
            {
               rptpList.push(packet.readShort())
            }
            trace("switch_response:"+rptpList.length.toString());
            callback("availRPTPS","response",rptpList)
            break;
          case 32769 :
            var rptp:int=packet.readByte();
           
            break;
          default:
            Alert.show("Not Handled "+d2h(swt_submsg) + "," + swt_submsg.toString());
            break
        }
      }
      /////////////////
      // d2h
      // int to hex string
      // d - decimal number
      // returns hex number as a string
      ////////////////
      public function d2h(d:int):String{
         var c:Array=['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'];
         var result:String="0x";
         for(var i:int=3;i>=0;i--)
         {
           var chidx:int=d/Math.pow(16,i);
           result+=c[chidx];
           d=d-chidx*Math.pow(16,i);
         }
         return result;
      }
      ////////////
      // close - Closes the socket.
      ////////////
      public function close():Boolean {
         m_socket.close();
         return(true);
      }
      public function connected():Boolean {
      	return m_socket.connected;
      }

      //////
      // PROTOCOL Functions that generate messages.
      //////


      ////////////
      // logoff - log out of analyzer.
      ////////////
      public function logoff():void {
      	         var ba:ByteArray= new ByteArray();
         ba.endian="littleEndian";
         var packetDetail:Array = ["04",  ba];
         if (! m_socket.connected ) {
            return;
         }
         //wait4ack="logoff";
      
         
         queueCommand("logoff",packetDetail,m_hmid);
        // m_socket.close();
      }
      ////////////
      // logon - log on to the analyzer.
      ////////////
      public function logon():Boolean {
         var ba:ByteArray= new ByteArray();
         ba.endian="littleEndian";
         ba.writeByte(0);
         var packetDetail:Array = ["03",  ba]; //command, msgLength, msg
         queueCommand("logon",packetDetail);
         return(true);
      }
      
      ////////////
      // getServerInfo - Request information about the host.
      ////////////
      public function getServerInfo():void {
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeByte(0);
      	 ba.writeByte(0);
      	 ba.writeByte(12);
      	 ba.writeByte(0);

         var packetDetail:Array = [ "20",  ba];
         
         queueCommand("getServerInfo",packetDetail);
      }
      ////////////
      // getHardwareInfo - Request information about the host's hardware.
      ////////////
      public function hardwareInfo():void {
         var ba:ByteArray= new ByteArray();
         ba.endian="littleEndian";
         ba.writeShort(0);
         ba.writeShort(7);
         var packetDetail:Array = ["20",  ba]; //command, msgLength, msg
         queueCommand("hardwareInfo",packetDetail);
      }
      public function connectionInfo():void {
         var ba:ByteArray= new ByteArray();
         ba.endian="littleEndian";
         ba.writeShort(0);
         ba.writeShort(16);
         ba.writeShort(0);
         var packetDetail:Array = ["20",  ba]; //command, msgLength, msg
         queueCommand("connectionInfo",packetDetail);
      }
      public function getFirmware():void {
         
         var ba:ByteArray= new ByteArray();
         ba.endian="littleEndian";
         ba.writeShort(0);
         ba.writeShort(4);
         var packetDetail:Array = ["20",  ba]; //command, msgLength, msg
         queueCommand("getFirmware",packetDetail);
      }
      public function availRPTPS():Boolean {
         var ba:ByteArray= new ByteArray();
         ba.endian="littleEndian";
         ba.writeShort(0);
         ba.writeShort(0x8009);
         var packetDetail:Array = ["80",  ba]; //command, msgLength, msg
         queueCommand("availRPTPS",packetDetail);
         return(true);
        
      }
      public function newMode(mode:int):void {
         var ba:ByteArray=new ByteArray();
         ba.writeByte(mode);
         ba.endian="littleEndian";
         var packetDetail:Array = [ "94",  ba];
         Alert.show(ba.toString().length.toString());
        
         queueCommand("newMode",packetDetail);
      }
      public function listHM():void {
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeByte(0);
      	 ba.writeByte(0);
      	 ba.writeByte(20);
      	 ba.writeByte(0);

         queueCommand("listHm",["20",ba],"99");
      }
      public function getSettings():void {
         
      	 var ba:ByteArray=new ByteArray();
      	 ba.writeByte(0);
      	 ba.writeByte(0);
      	 ba.writeByte(1);
      	 ba.writeByte(0);
         var packetDetail:Array = [ "20", ba];
         
         queueCommand("getSettings",packetDetail);
      }
      public function setSettings(mode:int,settings:SettingsObj):void {// TODO... This is going to get complicated
      //[ "SA", "SS", "BAS", "DCP", "SM1", "SM2", "SM6", "SMn",
      //"HUM", "NI", "FR", "DM", "", "MONITORING", "TDMA", "QAM", "MONITORING", "",
      //"DIGITAL MONITORING", "ANALOG MONITORING"];	
         settings.mode=m_modes[settings.MODE];
        
         queueCommand("setSettings",["20",settings.toByteArray()]);
      }

      public function listNodes(node_start:int):void {
 
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeShort(0);
      	 ba.writeShort(21);
      	 ba.writeShort(node_start);
      	 ba.writeByte(1);
         var packetDetail:Array = [ "20", ba];
         queueCommand("listNodes",packetDetail);
      }
 
      public function stopTrace():void {

      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeShort(1);
         var packetDetail:Array = [ "98", ba];
         queueCommand("stopTrace",packetDetail);
         m_socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
      }
      public function getThreshold():void {


      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeShort(0);
      	 ba.writeShort(11);
         var packetDetail:Array = [ "20", ba];
         queueCommand("threshold",packetDetail);
      }
      public function trigger(trigger_count:int=0):void {
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
         if (trigger_count == 1)
         {
      	   ba.writeShort(1);
         }
         else
         {
      	   ba.writeShort(0);
         }
         var packetDetail:Array = [ "98", ba];
 
         trace("QUEUEING TRIGGER");
         queueCommand("trigger",packetDetail);
      }
      public function threshold(node_start:int):void {
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeShort(0);
      	 ba.writeShort(17);
         var packetDetail:Array = [ "20", ba];
         queueCommand("threshold",packetDetail);
      }
      public function selectRPTP(rptp:int):void {
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeShort(0);
      	 ba.writeUnsignedInt(rptp);
         var packetDetail:Array = [ "80", ba];
         queueCommand("selectRPTP",packetDetail);
      }
      public function getRPTP():void {
       
      	 var ba:ByteArray=new ByteArray();
         ba.endian="littleEndian";
      	 ba.writeShort(0);
      	 ba.writeShort(0x8001);
         var packetDetail:Array = [ "80", ba];
         queueCommand("getRPTP",packetDetail);
      }
      
      private function connect():void {

         if (m_socket.connected ) {
            return;
         }
         try {
            m_socket.connect(  m_instr_address, m_instr_port);
         }
         catch( error:SecurityError ) {
            trace("connect error:" + error);
         }
      }
      private function fault(fault:FaultEvent):void
      {
         trace(fault.toString());
      }
      public function start():void {

         //ExternalInterface.addCallback("stopTrace", logoff );
         if ( ! m_instr_address ) {
            trace("No host given");
         } 
         createListeners();
         connect();
      }
      
      private function createListeners():void {
         m_socket.addEventListener(Event.CONNECT, onConnect );
         m_socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
         m_socket.addEventListener(Event.CLOSE,onCloseSocket);
      }

      private function onCloseSocket(event:Event):void {
      	callback("close");
      }
      private function onConnect(event:Event):void {
         callback("connect");
      }
      public function onSocketData( event:ProgressEvent ):void {
         var bytes:ByteArray= new ByteArray();
         trace("onSocketData Start");
         while (m_socket.bytesAvailable)
         {
           bytes=readPacket();
           parsePacketData(bytes);   
         }
         trace("onSocketData End");
      }
      private function processPacket(p:ByteArray):void {
         var data:String = new String;
         //addText("Received packet from server");
         for ( var i:int =0; i< p.length; i++) {
            data+=String.fromCharCode(p[i]);
         }
      }

      private function readPacket():ByteArray {
         var packet:ByteArray = new ByteArray();
         var length:int;
         var readMore:Boolean = true;
         var packetPrefixFound:Boolean = false;
         
           while (m_socket.bytesAvailable > 0  && !packetPrefixFound) //As long as bytes are available then lookd for [1][2] in packet.
           {
              if (m_socket.readByte()== 1)
              {
                  if (m_socket.readByte()==2)
                  {
                    packetPrefixFound=true;
                  }
              }
           }
           if (packetPrefixFound)
           {
             packet.writeByte(1);
             packet.writeByte(2);
              while(readMore) {
                if ( m_socket.bytesAvailable >= 13 ) { // Read the header 
                  m_socket.readBytes(packet,2,13);
                  readMore=false;

                }
              }
              length=parseInt(String.fromCharCode(packet[12],packet[13],packet[14]))+4
              
              readMore=true;
              while(readMore ) {
                if (length <= m_socket.bytesAvailable ) {
                  m_socket.readBytes(packet,15,length);
                  readMore=false;
                }
              }
          }
          return(packet);
      }
      private function queueCommand(msg_type:String,args:Array,dst:String="--"):void
      {
         var obj:Object={msg_type : msg_type,args : args, dst : dst};
         m_msg_queue.put(obj);
         dequeueCommand();
         
      }
      private function dequeueTimerHandler(event:TimerEvent):void {
         dequeueCommand();
      }
      private function dequeueCommand():void {
         while (m_msg_queue.length() > 0)
         {   trace("PEEK MSG TO SEND:"+m_msg_queue.peek().msg_type);
            /*Before we send a logoff we should make sure we recieved all the responses
              from the previously sent messages. Also make sure that there are no pending messages left*/
            
            if ((m_msg_queue.peek().msg_type =="logoff") && (m_response_queue.length()!=0))
            {
               return;
            }
            /*Before we send a logon we should make sure we recieved all the responses
              from the previously sent messages*/
            if ((m_msg_queue.peek().msg_type =="logon") && (m_response_queue.length()!=0))
            {
               return;
            }
            
            sendCommand(m_msg_queue.get());
         }
      }
      private function sendCommand(obj:Object):void {  
         var args:Array=obj.args;
         var dst:String=obj.dst;
         var msg_type:String=obj.msg_type;
         trace("SendMsg Type:" + msg_type);
         
         if (dst=="--") {dst=m_hmid}
         var packet:ByteArray = buildPacket(args,dst);
         //displayPacket(packet);
         m_socket.writeBytes(packet);
         var packet_str:String;
         var i:int;
         for (i=0;i<packet.length;i++)
         {
            packet_str+=packet[i].toString()+",";
         }
         try {
           m_socket.flush();
         }
         catch(error:IOError) {
           trace("m_socket.flush error " + error);
         }
         m_response_queue.put(msg_type);

      }

      private function buildPacket(args:Array,dst:String):ByteArray {
      
         var packet:ByteArray = new ByteArray();
         var crc:String = new String();
         var c:uint;
         var i:int=0;
         var len:String=args[1].length.toString();
         if (args.length > 2)
         {
            throw "Args not correct";
         }
         if (parseInt(len)<10)
         {
            len="00".concat(len)
         }
         else if (parseInt(len)<100)
         {
            len="0".concat(len)
         }
   
         trace("Building packet for device" + dst);
         packet.writeByte(HD0);
         packet.writeByte(HD1);
         packet.writeByte(AS0);
         packet.writeByte(AS1);
         packet.writeByte(dst.charCodeAt(0));
         packet.writeByte(dst.charCodeAt(1));
         args[1].position=0;
         for ( i=0; i< args[0].length; i++) {
            packet.writeByte(args[0].charCodeAt(i));
         }
         //packet.writeByte(m_default_node_number);
         packet.writeByte(0x0030);
         packet.writeByte(0x0030);
         packet.writeByte(0x0031);
         packet.writeByte(0x0030);
         packet.writeMultiByte(len,"us-ascii");
         var arg1_class_name:String=describeType(args[1]).@name.toString();
         trace(arg1_class_name + args[1].length.toString() + "," + packet.length.toString());
	 args[1].position=0;
         packet.writeBytes(args[1],0,args[1].length);
         trace(arg1_class_name + args[1].length.toString() + "," + packet.length.toString());
         
         c = calcCRC(packet);
         crc = c.toString(16);
         packet.writeByte(parseInt(crc.charAt(0) + crc.charAt(1), 16));
         packet.writeByte(parseInt(crc.charAt(2) + crc.charAt(3), 16));
         packet.writeByte(HF0);
         packet.writeByte(HF1);
         return(packet);
      }
   
      private function calcCRC(packetBA:ByteArray):int
      {
         var accum:int = 0;
         var crcIndex:int;
         for (var i:int=0; i < packetBA.length ; i++ ) {
            crcIndex=((accum >> 8) ^ uint(packetBA[i]));
            accum=((accum << 8 ) ^ (m_crc_table[crcIndex])) & MAX_SHORT;
         }
         return(accum);
      }
      
        
}
      
}
