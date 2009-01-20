/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Time formatter thanks to the JW Player Project
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php 
 */
 
package org.flowplayer.captions
{
	public class NumberFormatter
	{
		public function NumberFormatter()
		{
		}

		
		public static function seconds(str:String, timeMultiplier:Number = 1000):Number {
					str = str.replace(",",".");
	                var arr:Array = str.split(':');
	                var sec:Number = 0;
	                if (str.substr(-1) == 's') {
	                        sec = Number(str.substr(0,str.length-1));
	                } else if (str.substr(-1) == 'm') {
	                        sec = Number(str.substr(0,str.length-1)) * 60;
	                } else if(str.substr(-1) == 'h') {
	                        sec = Number(str.substr(0,str.length-1)) *3600;
	                } else if(arr.length > 1) {
	                        sec = Number(arr[arr.length-1]);
	                        sec += Number(arr[arr.length-2]) * 60;
	                        if(arr.length == 3) {
	                                sec += Number(arr[arr.length-3]) *3600;
	                        }
	                } else {
	                        sec = Number(str);
	                }
	                return Math.round(sec * timeMultiplier / 100) * 100;
	               // return sec;
	      }

	}
}