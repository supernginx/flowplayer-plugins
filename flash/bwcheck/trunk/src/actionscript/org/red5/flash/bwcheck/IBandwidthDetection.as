/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.red5.flash.bwcheck
{
	import flash.net.NetConnection;
	
	public interface IBandwidthDetection
	{
		
		function start():void;
		function set url(url:String):void;
		function set service(service:String):void;
		function set connection(connect:NetConnection):void;
        function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void;
	}
}