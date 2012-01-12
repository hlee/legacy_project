package com.sunrisetelecom.utils
{
    import com.sunrisetelecom.avantron.Queue;
    
    import flash.errors.IOError;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.TimerEvent;
    import flash.net.Socket;
    import flash.system.Security;
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import flash.utils.Timer;
    
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.Application;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.http.HTTPService;
    import mx.utils.ArrayUtil;
    import mx.utils.URLUtil;

    public class CommAgent extends Object
    {
        private var callback:Function;
        private var as0:int = 49;
        private var as1:int = 48;
        private var ad0:int = 48;
        private var ad1:int = 49;
        private var hd0:int = 1;
        private var hd1:int = 2;
        private var hf0:int = 3;
        private var hf1:int = 4;
        private var pendingTraces:int=0;
        private var defaultNodeNumber:String = '001';
        private var connectHost:String = "127.0.0.1"
        private var connectHostPort:Number = 3015;
        private var connectPort:String="3000";
        private var socket:Socket = new Socket();
        private var andShort:uint = 65535;
        private var msgTypes:Object = new Object();
        private var avantronTraceConstant:Number = 70 / 1024.0;
        private var imgYoffset:int =273; 
        private var imgXoffset:int = 0;
        public var z:int=0;
        private var userlist:ArrayCollection;

        public var swt:String;
        public var ofs:String;
        private var _realviewService:HTTPService = new HTTPService();
        private var _realworxService:HTTPService = new HTTPService();
        
        private var _realviewUrl:String = null;

        private var msgQueue:Queue = new Queue();
        private var responseQueue:Queue = new Queue();
        private var msgTimer:Timer = new Timer(400);

      
        private var hmid:String="01";
        //public var settings:SASettings = new SASettings();
        private var ack:int = 0;
        //public var muxPortDefault:int=1;
        //public var muxPort:int = root.loaderInfo.parameters.swPort;
        //public var connectHost:String = root.loaderInfo.parameters.host;
        public var isLoggedOn:Boolean=false;
        [Bindable]
        public var topOfScreenLvl:int;
        public var imageAvg:Array = new Array();
        public var imgCnt:int;
        private var modes:Array = ["SA", "SS", "BAS", "DCP", "SM1", "SM2", "SM6", "SMn",
            "HUM", "NI", "FR", "DM", "", "MONITORING", "TDMA", "QAM", "MONITORING", "",
            "DIGITAL MONITORING", "ANALOG MONITORING"];
         
        private var crcTable:Array = [
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
        ];
        
        private var _viewer:IViewer = null;
          
        public function CommAgent(viewer:IViewer, resp_callback:Function):void
        {
            _viewer = viewer;
            callback = resp_callback;
            socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            msgTimer.addEventListener("timer", dequeueTimerHandler);
            msgTimer.start();  
        }
        
        private function set status(text:String):void
        {
            if(_viewer)
            {
                _viewer.setStatus(text);
            }
        }
        
        private function ioErrorHandler(event:IOErrorEvent):void
        {
            Alert.show("Unable to connect to RealView Server. Please verify status and reload page");
        }
        
        public function set_hmid(arg_hmid:String):void
        {
            hmid = arg_hmid;
        }
        
        public function parsePacketData(packet:ByteArray):void
        {  
            packet.endian=Endian.LITTLE_ENDIAN;
            var commandObj:Object = new Object();
            var dataPoints:Array;
            var i:int;

            //TOMMIE the state machine is embedded here.  It needs to be broken out.
            var msg_type:int=packet[6]*256+packet[7];
            var response_type:String;
            trace("RECVING: " + msg_type);
            //msg_type is in the format of a short. 
            //The short is actually two bytes that refer to the ascii characters that make up the message type.
            //IMHO I compromised code readibility for performance here.
            switch(msg_type)
            {
                case 12337: //01 ACK
                    response_type=String(responseQueue.get());
                    trace("Ack:"+response_type);
                    switch (response_type)
                    {
                        case "logon":
                            callback("logon","ack");
                            break;
                        case "logoff":
                            callback("logoff","ack");
                            break;
                        case "newMode" : 
                            callback("newMode","ack");
                            break;
                        default:
                            break;
                    }
                    break;     
                case 12338://02 NAK
                    response_type=String(responseQueue.get());
                    trace("Nak: " + response_type);             
                    callback(response_type, "nak",packet[15]);
                    break; 
                case 12848://20 GENERAL COMMANDS
                    general_response(packet);
                    break;
                case 12341: //05 IMAGE TRACE
                    //IMAGE SPEC
                    var dp:Array = new Array(); //dataPoints
                    var image:Array = new Array();
                    var val:int;
                    imgCnt++;
                    for (i=0; i<125; i++)
                    {
                        image[4*i] = (( packet[5*i+16] << 2) | (packet[5*i+17] >> 6)) *avantronTraceConstant;
                        image[4*i+1] = (((packet[5*i+17] & 0x3F)<< 4) | (packet[5*i+18] >> 4)) *avantronTraceConstant;
                        image[4*i+2] = (( (packet[5*i+18] & 0xF)<< 6) | (packet[5*i+19] >> 2)) *avantronTraceConstant;
                        image[4*i+3] = (((packet[5*i+19] & 0x3) << 8)| (packet[5*i+20] >> 0))*avantronTraceConstant;                
                    }
                    callback("trigger", "response", image);
                    pendingTraces--;
                    trace("Pending Traces--: " + pendingTraces);
                    break;
                case 14384: //80 SWITCH COMMAND
                    packet.position = 17;
                    switch_response(packet);
                    break;
                default:
                    //addText("received unknown msg");
                    break;
            }
        }
        
        private function general_response(packet:ByteArray):void
        {
            var i:int;
            var msgLen:int = (packet[12] - 48) * 100+(packet[13] - 48) * 10 + packet[14] - 48;
            var tmpBA:ByteArray = new ByteArray();
            tmpBA.endian = Endian.LITTLE_ENDIAN;
            var tmpObj:Object = new Object();
            
            switch(packet[17])
            {
                case 12:
                    packet.position=19;
                     var sysType:String=packet.readUTFBytes(20);
                     callback("getServerInfo","response",sysType);
                     break;
                case 04:
                    packet.position=19;
                    //settings.HMFirmware=packet.readUTFBytes(16);
                    break;
                case 14:
                    packet.position=19;
                    var option_value:int=packet.readByte();
                    var txt_msg:String=packet.readUTFBytes(packet.bytesAvailable);
                    // Alert.show("MSG"+txt_msg);
                    //settings.hwType=packet.readUTFBytes(20);
                    break;
                case 17:
                    packet.position = 19;
                    var success:int=packet.readByte();
                    break;
                case 20:
                    //addText("recvd info " + packet[17]);
                    //addText("length " + msgLen);
                    packet.position=19;
                    tmpBA.writeBytes(packet,19,packet.length-19);
                    var obj_count:int=packet.readUnsignedShort();
                    var idx:int;
                    var anl_list:Array=[];
                    for(idx=0;idx<obj_count;idx++)
                    {
                        var hmid:uint= packet.readUnsignedByte();
                        var avail:uint=packet.readUnsignedByte();
                        var name:String=packet.readUTFBytes(20);
                        if (avail != 0)
                        {
                            anl_list.push({label:name, data:hmid});
                        }
                    }
                    callback("listHM","response",anl_list);
                    break;
                case 21:
                    //addText("received nodes");
                    packet.position=19;
                    var start_node:int=packet.readUnsignedShort();
                    var alphaorder:int=packet.readUnsignedByte();
                    var node_list:Array=[];
                    var raw_node_list:Array=[];
                    var nodeCount:int=packet.readUnsignedShort();
                    //raw_node_list=packet.toString().split('\0000');
                    for (i=0;i<nodeCount;i++)
                    {
                        var pos:int=packet.readUnsignedShort();
                        var end_idx:int=packet.toString().indexOf("\u0000",packet.position);
                        var name_len:int=end_idx-packet.position;
                        var node_name:String=packet.readUTFBytes(name_len);
                        packet.position++;
                        node_list[pos]=node_name;
            
                    }
                    callback("listNodes","response",{node_list: node_list, start_node: start_node, node_count: nodeCount});
                    break;
                case 1:
                    var x:int; //garbage var
                    var result:Object={att: 0,cfreq:0,span:0,sweep:0,rbw:0,vbw:0,vscale:0,htime:0};
                    tmpBA.writeBytes(packet);
                    tmpBA.position=20;
                    //mode = modes[int(tmpBA.readByte())];
                    tmpBA.position+=5; //4 if I get mode
                    result.att= tmpBA.readUnsignedShort();
                    tmpBA.position+=2;
                    
                    result.cfreq= String(tmpBA.readDouble()/1000000);
                    result.span =String(tmpBA.readDouble()/1000000);
                    tmpBA.position+=6;
                    trace("Sweep Pos:" + tmpBA.position);
                    result.sweep = String(tmpBA.readUnsignedShort());
                    result.htime = tmpBA.readDouble();
                    trace("RBW Pos:" + tmpBA.position);
                    result.rbw = String(tmpBA.readDouble()/1000);
                    result.vbw = String(tmpBA.readDouble()/1000);
                    tmpBA.position+=6;
                    result.vscale = tmpBA.readUnsignedShort();
                    tmpBA.position+=2;
                    /*settings["haveVertMarker1"]=tmpBA.readBoolean();
                    settings["haveVertMarker2"]=tmpBA.readBoolean();
                    settings["haveHorizMarker1"]=tmpBA.readBoolean();
                    settings["haveHorizMarker2"]=tmpBA.readBoolean();
                    settings["vertMarker1Pos"]=tmpBA.readDouble();
                    settings["vertMarker2Pos"]=tmpBA.readDouble();
                    settings["horizMarker1Pos"]=tmpBA.readUnsignedShort();
                    settings["horizMarker2Pos"]=tmpBA.readUnsignedShort();*/
                    callback("getSettings","response",result);                   
                    break;
                default:
                    trace(packet.toString());
                    break;
            }
        }
        
        private function switch_response(packet:ByteArray):void
        {
            var swt_submsg:int;
            var rptpList:Array=new Array();
              
            swt_submsg=packet.readUnsignedShort();
            switch(swt_submsg)
            {
                case 32777:
                    var rptp_count:int=packet.readUnsignedShort();
                    if (rptp_count > 256)
                    {
                        Alert.show("Unable to pull list of ports.");
                        break;
                    }
                    //TODO handle error code
                    for (var i:int=0;i<rptp_count;i++)
                    {
                        rptpList.push(packet.readShort());
                    }
                    callback("availRPTPS","response",rptpList);
                    break;
                case 32769:
                    var rptp:int=packet.readByte();
                    break;
                default:
                    Alert.show("Not Handled "+d2h(swt_submsg) + "," + swt_submsg.toString());
                    break;
            }
        }
        
        public function d2h(d:int):String
        {
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

        //////
        // PROTOCOL Functions
        //////
        public function logoff():void
        {
            var packetDetail:Array = ["04",  ""];
            if (! socket.connected)
            {
                return;
            }
            //wait4ack="logoff";
            this.status = "Get Settings";
         
            queueCommand("logoff", packetDetail, hmid);
            //socket.close();
        }
        
        public function close():Boolean
        {
            socket.close();
            return true;
        }
        
        public function logon():Boolean
        {
            var packetDetail:Array = ["03", String.fromCharCode(0)]; //command, msgLength, msg
            queueCommand("logon",packetDetail);
            return true;
        }
      
        public function getServerInfo():void
        {
            this.status = "Get Server Info";
            var packetDetail:Array = ["20", "\u0000\u0000\u000c\u0000"];
            ack++;
            queueCommand("getServerInfo", packetDetail);
        }
        
        public function hardwareInfo():void
        {
            var packetDetail:Array = ["20", "\u0000\u0000\u0007\u0000"];
        }
        
        public function connectionInfo():void
        {
            var packetDetail:Array = ["20", "\u0000\u0000\u0010\u0000\u0000\u0000"];
        }
        
        public function getFirmware():void
        {
            var packetDetail:Array = ["20", "\u0000\u0000\u0004\u0000"];
            queueCommand("getFirmware", packetDetail);
        }
        
        public function availRPTPS():void
        {
            this.status = "Get avail RPTPS";
            var packetDetail:Array = ["80", "\u0000\u0000\u0009\u0080"];
            queueCommand("availRPTPS",packetDetail);
        }
        
        public function newMode():void
        {
            var packetDetail:Array = ["94", "\u0000"];
            queueCommand("newMode",packetDetail);
        }
        
        public function listHM():void
        {
            this.status = "Get HM List";
            var packetDetail:Array = ["20", "\u0000\u0000\u0014\u0000"];
            queueCommand("listHm", packetDetail, "99");
        }
        
        public function getSettings():void
        {
            this.status = "Get Settings";
            var packetDetail:Array = ["20", "\u0000\u0000\u0001\u0000"];
            queueCommand("getSettings", packetDetail);
        }
        
        public function setSettings():void
        {
            this.status = "Set Settings";
            var packetDetail:Array = [ "20", "\u0000\u0000\u0001\u0000"];
            queueCommand("getSettings", packetDetail);
        }

        public function listNodes(node_start:int):void
        {
            this.status = "Get Node List for Analyzer";
            var firstpart:int=node_start & 255;
            var secondpart:int=node_start >> 8;

            var packetDetail:Array = ["20", "\u0000\u0000\u0015\u0001"+ 
                String.fromCharCode(firstpart)+
                String.fromCharCode(secondpart) + "\u0001"];
            queueCommand("listNodes", packetDetail);
        }
 
        public function stopTrace():void
        {
            this.status = "Stop Trace";
            var packetDetail:Array = [ "98", "\u0001\u0000"];
            queueCommand("stopTrace", packetDetail);
            socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        }
      
        public function getThreshold():void
        {
            this.status = "Get Node List for Analyzer";
            var packetDetail:Array = ["20", "\u0000\u0000\u0011\u0000"];
            queueCommand("threshold",packetDetail);
        }
        
        public function trigger(trigger_count:int=0):void
        {
            var packetDetail:Array = ["98", "\u0000\u0000"]; //command, msgLength, msg
            if (pendingTraces > 0)
            {
                trace("pendingTraces(" + pendingTraces + ") > 0, so return.");
                return;
            }
            if (trigger_count == 1)
            {
                packetDetail= ["98","\u0001\u0000"]; //command, msgLength, msg
            }
            if ((msgQueue.length() == 0) )
            {
                pendingTraces++;
                trace("Pending Traces++: " + pendingTraces);
                queueCommand("trigger",packetDetail);
            }
            else
            {
                trace("msgQueue is not empty! So can't trigger");
            }
        }
        
        public function threshold(node_start:int):void
        {
            var packetDetail:Array = ["20", "\u0000\u0000\u0011\u0000"]; 
            queueCommand("threshold", packetDetail);
        }
        
        public function selectRPTP(rptp:int):void
        {
            this.status = "Select RPTP";
            trace("Select RPTP: " + rptp);
            var packetDetail:Array = ["80", "\u0004\u0000" + String.fromCharCode(rptp) + "\u0000"];
            pendingTraces = 0;
            trace("Pending Traces init when select RPTP: " + pendingTraces);
            queueCommand("selectRPTP",packetDetail);
        }
        
        public function getRPTP():void
        {
            this.status = "Get RPTP";
            var packetDetail:Array = ["80", "\u0000\u0001\u0080"];
            queueCommand("getRPTP",packetDetail);
        }
      
        public function connect():void
        {
            if (flash.system.Security.sandboxType != "remote")
            {
                //Just to have something to debug with when running from 
                //Local drive
                connectHost = "24.197.97.170";
                connectPort = "80";
            }
            else
            {
                var url:String = Application.application.url;
                connectHost=URLUtil.getServerName(url);
                connectPort=URLUtil.getPort(url).toString(); 
                if ((connectPort=="") || (connectPort=="0"))
                {
                    connectPort="80";
                    trace("Connect Port: " + connectPort);
                }
            }
            if (socket.connected)
            {
                return;
            }
            try
            {
                pendingTraces = 0;
                trace("Pending Traces init: " + pendingTraces);
                socket.connect(connectHost, connectHostPort);
                
                _realworxService.url = "http://"+connectHost+":"+connectPort+"/users/user_list";
                _realworxService.addEventListener(ResultEvent.RESULT, update_users_result);
                
                _realviewUrl = "http://" + connectHost + ":8008/GET_CLIENT_LIST_XML";
                _realviewService.url = _realviewUrl;
                _realviewService.addEventListener(ResultEvent.RESULT, update_ips_result);
                _realviewService.addEventListener(FaultEvent.FAULT, fault);

                var iplistTimer:Timer = new Timer(5000, 0);
                iplistTimer.addEventListener(TimerEvent.TIMER, update_users);
                iplistTimer.start();
            }
            catch(error:SecurityError)
            {
                trace("connect error:" + error);
            }
        }
        
        private function fault(fault:FaultEvent):void
        {
            trace("Fault Error(" + fault.messageId + "): " + fault.toString());
        }
        
        private function update_users(event:TimerEvent=null):void
        {
            _realviewService.url = _realviewUrl + "?t=" + Math.round(Math.random() * 1000000);
            
            _realworxService.send();
            trace("System Total Memory Usage: " + System.totalMemory.toString());
        }
        
        private function update_users_result(event:ResultEvent):void
        {
            try
            {
                var objs:Object = event.result.users;
                if (objs == null)
                {
                    userlist = new ArrayCollection();
                }
                else if (objs.user is ArrayCollection)
                {
                    userlist = objs.user;
                }
                else if (objs.user is ObjectProxy)
                {
                    userlist = new ArrayCollection(ArrayUtil.toArray(objs.user));
                }
                trace("User List Length: " + userlist.length);
                update_ips();
            }
            catch(e:Error)
            {
                trace("Update userlist error: " + e.message);
            }
        }
        
        private function update_ips(event:TimerEvent=null):void
        {
            _realviewService.send();
        }
        
        private function update_ips_result(event:ResultEvent):void
        {
            var iplist:ArrayCollection = null;
            var objs:Object = event.result.HecControllerInfo.clientNodes;
            if(objs != null)
            {
                if(objs.client is ArrayCollection)
                {
                    iplist = objs.client;
                }
                else if(objs.client is ObjectProxy)
                {
                    iplist = new ArrayCollection(ArrayUtil.toArray(event.result.HecControllerInfo.clientNodes.client));
                }
            }

            if(!iplist)
            {
                iplist = new ArrayCollection();
            }
            
            for(var i:int = 0; i < iplist.length; i++)
            {
                iplist[i].user = iplist[i]["RemoteHost"];
                /*
                for(var j:int=0;j < userlist.length; j++)
                {
                    if(iplist[i]["RemoteHost"] == userlist[j]["live-ip"])
                    {
                        iplist[i].user = userlist[j].email;
                    }
                }
                */
                iplist[i].HMId = iplist[i]["HMId"];
                iplist[i].SwitchPosition = iplist[i]["SwitchPosition"];
            }
            callback("live_connections", "ack", iplist);
        }
        
        public function start():void
        {
            //ExternalInterface.addCallback("stopTrace", logoff );
            if ( ! connectHost )
            {
                trace("No host given");
            } 
            createListeners();
            connect();
        }
      
        private function createListeners():void
        {
            socket.addEventListener(Event.CONNECT, onConnect);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        }

        private function onConnect(event:Event):void
        {
            callback("connect");
        }
        
        public function onSocketData(event:ProgressEvent):void
        {
            var bytes:ByteArray= new ByteArray();
            trace("onSocketData Start");
            try
            {
	            while (socket.bytesAvailable)
	            {
	                bytes=readPacket();
	                parsePacketData(bytes);   
	            }
            }
            catch(e:Error)
            {
            	trace("Socket Error: " + e.message);
            }
            trace("onSocketData End");
        }
        
        private function processPacket(p:ByteArray):void
        {
            var data:String = new String;
            //addText("Received packet from server");
            for ( var i:int =0; i< p.length; i++)
            {
                data+=String.fromCharCode(p[i]);
            }
        }

        private function readPacket():ByteArray
        {
            var packet:ByteArray = new ByteArray();
            var length:int;
            var readMore:Boolean = true;
            var packetPrefixFound:Boolean = false;
         
            while (socket.bytesAvailable > 0  && !packetPrefixFound) //As long as bytes are available then lookd for [1][2] in packet.
            {
                if (socket.readByte()== 1)
                {
                    if (socket.readByte()==2)
                    {
                        packetPrefixFound=true;
                    }
                }
            }
            if (packetPrefixFound)
            {
                packet.writeByte(1);
                packet.writeByte(2);
                while(readMore)
                {
                    if (socket.bytesAvailable >= 13)
                    {
                        // Read the header 
                        socket.readBytes(packet,2,13);
                        readMore=false;
                    }
                }
                length = parseInt(String.fromCharCode(packet[12],packet[13],packet[14]))+4
              
                readMore=true;
                while(readMore)
                {
                    if (length <= socket.bytesAvailable )
                    {
                        socket.readBytes(packet,15,length);
                        readMore=false;
                    }
                }
                z++;
            }
            return packet;
        }
        
        private function queueCommand(msg_type:String,args:Array,dst:String="--"):void
        {
            var obj:Object={msg_type : msg_type,args : args, dst : dst};
            msgQueue.put(obj);
            dequeueCommand();    
        }
        
        private function dequeueTimerHandler(event:TimerEvent):void
        {
            dequeueCommand();
        }
        
        private function dequeueCommand():void
        {
            while (msgQueue.length() > 0)
            {    
                /*Before we send a logoff we should make sure we recieved all the responses
                from the previously sent messages. Also make sure that there are no pending traces left*/
              
                if ((msgQueue.peek().msg_type =="logoff") && (responseQueue.length()!=0))
                {
                    return;
                }
                /*Before we send a logon we should make sure we recieved all the responses
                from the previously sent messages*/
                if ((msgQueue.peek().msg_type =="logon") && (responseQueue.length()!=0))
                {
                    return;
                }
                sendCommand(msgQueue.get());
            }
        }
        
        private function sendCommand(obj:Object):void
        {  
            var args:Array=obj.args;
            var dst:String=obj.dst;
            var msg_type:String=obj.msg_type;
            trace("SendMsg Type:" + msg_type);
          
            if (dst == "--")
            {
                dst = hmid;
            }
            var packet:ByteArray = buildPacket(args,dst);
            //displayPacket(packet);
            socket.writeBytes(packet);
            var packet_str:String = "";
            var i:int;
            for(i = 0; i < packet.length; i++)
            {
                packet_str += packet[i].toString(16);
                if(i != packet.length - 1)
                {
                    packet_str += ",";
                }
                
            }
            try
            {
                trace("socket message:" + packet_str);
                socket.flush();
            }
            catch(error:IOError)
            {
                trace("socket.flush error: " + error);
            }
            responseQueue.put(msg_type);
        }
        
        private function recvdAckListener(evt:Event):void
        {
            //trace("recvdAck listener");
            getServerInfo();
        }

        private function buildPacket(args:Array,dst:String):ByteArray
        {
            var packet:ByteArray = new ByteArray();
            var crc:String = new String();
            var c:uint;
            var i:int=0;
            
            var len:int = args[1].length;
            var lenStr:String = len.toString();
            if(args.length > 2)
            {
                throw "Args not correct";
            }
            
            if(len < 10)
            {
                lenStr = "00".concat(lenStr);
            }
            else if(len < 100)
            {
                lenStr = "0".concat(lenStr);
            }
            
            if(lenStr.length != 3)
            {
                trace("command length error: " + lenStr);
                lenStr = "000";
            }

            //trace("Building packet for device" + dst);
            packet.writeByte(hd0);
            packet.writeByte(hd1);
            packet.writeByte(as0);
            packet.writeByte(as1);
            packet.writeByte(dst.charCodeAt(0));
            packet.writeByte(dst.charCodeAt(1));
            for(i = 0; i < args[0].length; i++)
            {
                packet.writeByte(args[0].charCodeAt(i));
            }
            //packet.writeByte(defaultNodeNumber);
            packet.writeByte(0x0030);
            packet.writeByte(0x0030);
            packet.writeByte(0x0031);
            packet.writeByte(0x0030);
            
            for(i = 0; i < 3; i++)
            {
                packet.writeByte(lenStr.charCodeAt(i));
            }
            //packet.writeMultiByte(len, "us-ascii");

            for(i = 0; i < len; i++)
            {
                packet.writeByte(args[1].charCodeAt(i));
            }
            c = calcCRC(packet);
            crc = c.toString(16);
            trace("ACCUM:"+crc);
            if (crc.length == 3)
            {
                crc="0"+crc;
            }
            if (crc.length==2)
            {
                crc="00"+crc;
            }
            if (crc.length == 1)
            {
                crc="000"+crc;
            }
            if (crc.length == 0)
            {
                crc="0000";
            }
            packet.writeByte(parseInt(crc.charAt(0) + crc.charAt(1), 16));
            packet.writeByte(parseInt(crc.charAt(2) + crc.charAt(3), 16));
            packet.writeByte(hf0);
            packet.writeByte(hf1);
            return packet;
        }
   
        private function calcCRC(packetBA:ByteArray):int
        {
            var accum:int = 0;
            var crcIndex:int;
            for (var i:int=0; i < packetBA.length ; i++ )
            {
                crcIndex=((accum >> 8) ^ uint(packetBA[i]));
                accum=((accum << 8 ) ^ (crcTable[crcIndex])) & andShort;
                trace("ACCUM" + accum.toString());
                trace("crcIndex" + crcIndex.toString())
            }
            trace("--------");
            return accum;
        }
    }
}
