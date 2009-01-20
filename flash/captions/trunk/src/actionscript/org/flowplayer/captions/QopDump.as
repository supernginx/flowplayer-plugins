package org.flowplayer.captions {
 import flash.utils.describeType;
 public class QopDump {
  static var n:int = 0;
  static var str:String;
  // trace
  public static function echo(o:Object):void {
   trace( go(o) );
  }
  // return the result string
  public static function go(o:Object):String {
   str = "";
   dump(o);
   // remove the lastest \n
   str = str.slice(0, str.length-1);
   return str;
  }
  static function dump(o:Object) {
   var type:String = describeType(o).@name;
   if(type == 'Array') {
    dumpArray(o);
   } else if (type == 'Object') {
    dumpObject(o);
   } else {
    appendStr(o);
   }
  }
  static function appendStr(s:Object) {
   str += s + '\n';
  }
  static function dumpArray(a:Object):void {
   n++;
   var type:String;
   for (var i:String in a) {
    type = describeType(a[i]).@name;
    if (type == 'Array' || type == 'Object') {
     appendStr(getSpaces() + "[" + i + "]:");
     dump(a[i]);
    } else {
     appendStr(getSpaces() + "[" + i + "]:" + a[i]);
    }
   }
   n--;
  }
  static function dumpObject(o:Object):void {
   n++;
   var type:String;
   for (var i:String in o) {
    type = describeType(o[i]).@name;
    if (type == 'Array' || type == 'Object') {
     appendStr(getSpaces() + i + ":");
     dump(o[i]);
    } else {
     appendStr(getSpaces() + i + ":" + o[i]);
    }
   }
   n--;
  }
  static function getSpaces():String {
   var s:String ="";
   for(var i:int = 1; i < n; i++){
    s += "  ";
   }
   return s;
  }
 }
}