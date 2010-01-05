package org.flowplayer.bwcheck.util {

	import flash.utils.getDefinitionByName;
	
	public class FactoryMethodUtil {
		
		public static function getFactoryMethod(base:String, method:String):Class {
			 return Class(getDefinitionByName(base + ucFirst(method)));
		}
		
		public static function ucFirst(value:String):String {
			return String(value.toLowerCase().charAt( 0 ).toUpperCase() + value.substr( 1, value.length ).toLowerCase());
		}
	}
}
