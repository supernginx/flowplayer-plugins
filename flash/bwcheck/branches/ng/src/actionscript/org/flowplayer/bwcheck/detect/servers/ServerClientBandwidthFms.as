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

	import org.red5.flash.bwcheck.BandwidthDetection;
	
	/**
	 * @author danielr
	 */
	public class ServerClientBandwidthFms extends BandwidthDetection {

		private var _host:String;
		
		public function set host(host:String):void
		{
			_host = host;
		}
		
		public function onBWCheck(... rest):Number
		{
            dispatchStatus(rest);
            return 0;
		}

		public function onBWDone(... rest):void
		{
            if (rest[0] != undefined)
            {
	            log.debug("onBWDone() " + rest[0]);
				var obj:Object = new Object();
				obj.kbitDown = rest[0];
				obj.latency = rest[3];
				dispatchComplete(obj);
            }
		}
		
		
		override public function start():void
		{
            log.debug("start() calling service " + _service);
			_nc.client = this;
            _nc.call(_service, null);
		}

        public function close(... rest):void {
            log.debug("close()");
        }
	}
}