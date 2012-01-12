package com.sunrisetelecom.utils {
  import mx.utils.ArrayUtil;
  import mx.controls.Alert;
  import flash.utils.ByteArray;
  public class SystemFile extends Object {
    public var channel_plan:Array=new Array();
    public var magic_nbr:uint;
    private var expected_sizes:Array=[48,380,58,20,96,44,13,17,5,63,23]

    private static function typeNotAssigned(obj:Object):Boolean
    {
      if (obj == null)
      {
        return false;
      }
      if (obj["digital"]==null )
      {
        return false;
      }
      if (obj["analog"]==null )
      {
        return false;
      }
      return true;
    }


    // I could not get the readMultiByte(utf-16) to work.
    // So I created this function.
    public static function unicodeToAscii(arr:ByteArray):String
    {
      var idx:int;
      var result:String=""
      for(idx=0;idx<arr.length;idx++)
      {
        if (idx%2==0)
        {
            result+=arr.readUTFBytes(1);
        }
      }
      return result;
    }
    public static function parseType2(block:ByteArray):Object
    {
      var obj:Object=new Object();
      var i:int=block.bytesAvailable;
      var tmp:ByteArray=new ByteArray();
      block.readBytes(tmp,0,10);
      obj["channel"]= unicodeToAscii(tmp);
      tmp=new ByteArray();
      block.readBytes(tmp,0,42);
      obj["name"]= unicodeToAscii(tmp);
      obj["type"]=block.readByte().toString();
      obj["direction"]=block.readByte().toString();
      obj["usefullscan"]=block.readByte().toString();
      obj["useminiscan"]=block.readByte().toString();
      obj["active"]=block.readByte().toString();
      obj["unittype"]=block.readByte().toString();
      trace("XX:["+i.toString()+"]" + obj.channel + "," +obj.name + "," + obj.type + "," + obj.direction + "," + obj.usefullscan);
      return obj;
    }
    public static function parseType3(block:ByteArray):Object
    {
      var obj:Object=new Object();
      block.endian="littleEndian";
      obj['centerfreq']=block.readUnsignedInt();
      obj['bandwidth']=block.readUnsignedInt();
      obj['modulation']=block.readUnsignedShort();
      obj['symbolrate']=block.readUnsignedInt();
      obj['polarity']=block.readUnsignedByte();
      obj['j83annex']=block.readUnsignedByte();
      obj['usefec']=block.readUnsignedByte();
      obj['equalizer']=block.readUnsignedByte();
      obj['docsis_ranging']=block.readUnsignedShort();
      obj['freq']=obj['centerfreq'];
      return obj;
    }
    public static function parseType4(block:ByteArray):Object
    {
      var obj:Object=new Object();
      block.endian="littleEndian";
      obj['videofreq']=block.readUnsignedInt();
      obj['modulation']=block.readUnsignedShort();
      obj['videodwelltime']=block.readUnsignedShort();
      obj['va1sep']=block.readUnsignedInt();
      obj['audio1dwelltime']=block.readUnsignedShort();
      obj['va2sep']=block.readUnsignedInt();
      obj['audio2dwelltime']=block.readUnsignedShort();
      obj['bandwidth']=block.readUnsignedInt();
      obj['freq']=obj['videofreq'];
      return obj;
    }

    public function SystemFile(data:ByteArray)
    {
      magic_nbr=data.readUnsignedInt();
      data.endian="littleEndian";
      var contin_read:Boolean=true;
      var iter:int=0;
       trace ("System file loading");
      //Alert.show("Bytes Started with:" + data.bytesAvailable.toString());
      while((data.bytesAvailable > 0) && (contin_read))
      {
        iter= iter + 1;
        var block_type:uint = data.readUnsignedShort();
        var block_size:uint = data.readUnsignedShort();
	trace("BLOCK TYPE:" + block_type.toString() + "," + "Block Size:" + block_size.toString());
	// verify block_size
	if (block_type == 65535)
	{
	   contin_read=false;
	   data.readMultiByte(block_size, "unicode");
	}
	else if (block_type > 20)
	{
	  data.readMultiByte(block_size, "unicode");
	  //Alert.show("in block type " + block_size.toString());
	}
	else if (block_size == expected_sizes[block_type])
	{
	  var block:ByteArray=new ByteArray();
	  data.readBytes(block, 0, block_size);
	  var idx:int=channel_plan.length-1;
	  trace ("Block : " + block.toString());
	  switch(block_type)
	  {
	    case 2:
	      channel_plan.push(parseType2(block));
	    break;
	    case 3:
	      if (idx <= -1)
	      {
	        throw("No block type 2");
	      }
	      else if (typeNotAssigned(channel_plan[idx]))
	      {
	        throw("Got type 3 unexpected");
	      }
	      channel_plan[idx]["digital"]=parseType3(block);
              channel_plan[idx]['freq']=channel_plan[idx]["digital"]['freq'];
	    break;
	    case 4:
	      if (channel_plan.length == 0)
	      {
	        throw("No block type 2");
	      }
	      else if (typeNotAssigned(channel_plan[idx]))
	      {
	        throw("Got type 4 unexpected");
	      }
	      channel_plan[idx]["analog"]=parseType4(block);
              channel_plan[idx]['freq']=channel_plan[idx]['analog']['freq'];
	    break;
	  }
	}
	else
	{
	  throw ("What the h ("+block_size.toString()+")!=("+expected_sizes[block_type].toString()+")" + "for" + block_type.toString() );
	}
      }
     

    }
  }
}
