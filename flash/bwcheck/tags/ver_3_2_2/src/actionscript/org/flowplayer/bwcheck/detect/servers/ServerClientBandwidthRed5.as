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
	public class ServerClientBandwidthRed5 extends BandwidthDetection
	{
		
		private var info:Object = new Object();
		private var res:Responder;
		
		public function ServerClientBandwidthRed5()
		{
			res = new Responder(onResult, onStatus);
			_service = "bwCheckService.onServerClientBWCheck";
		}

		public function onBWCheck(obj:Object):void
		{
			dispatchStatus(obj);
		}
			
		public function onBWDone(obj:Object):void 
		{ 
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
