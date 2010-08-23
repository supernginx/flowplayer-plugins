/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy
 * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */

package org.flowplayer.bwcheck.detect.servers
{

	import flash.net.Responder;

	import org.red5.flash.bwcheck.BandwidthDetection;
	
	/**
	 * @author danielr
	 */
	public class ServerClientBandwidthWowza extends BandwidthDetection
	{
		private var info:Object = new Object();
		private var res:Responder;
		private var _counter:int = 0;
		
		public function ServerClientBandwidthWowza()
		{
			res = new Responder(onResult, onStatus);
		}


        public function onBwCheck(obj:Object):Boolean
        {
            return onBWCheck(obj);
        }

        public function onBWCheck(obj:Object):Boolean
        {
            log.debug("onBWCheck");
            dispatchStatus(obj);
            return true;
        }

        public function onBWDone(...args):void
		{
            log.debug("onBWDone, " + info);
			var obj:Object = new Object();
			var kbitDown:int = args[0];
			var deltaDown:int = args[1];
			var deltaTime:int = args[2]; 
			var latency:int = args[3];
			obj.kbitDown = kbitDown;
			obj.delatDown = deltaDown;
			obj.deltaTime = deltaTime;
			obj.latency = latency;
			dispatchComplete(obj);
		}
		
		
		override public function start():void
		{
			_nc.client = this;
			_nc.call(_service,res);
		}
		
		protected function onResult(obj:Object):void
		{
			dispatchStatus(obj);
				
		}
		
		protected function onStatus(obj:Object):void
		{
			switch (obj.code)
			{
				case "NetConnection.Call.Failed":
					dispatchFailed(obj);
				break;
			}

		}
	}
}