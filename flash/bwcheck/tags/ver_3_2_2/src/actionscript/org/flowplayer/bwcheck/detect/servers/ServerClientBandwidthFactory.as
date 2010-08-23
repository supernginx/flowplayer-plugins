/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.bwcheck.detect.servers {

	import org.red5.flash.bwcheck.IBandwidthDetection;
	import org.flowplayer.bwcheck.util.FactoryMethodUtil;
	import flash.net.NetConnection;
	
	/**
	 * @author danielr
	 */
	public class ServerClientBandwidthFactory implements IBandwidthDetection {
		
		private var wowzaImpl:ServerClientBandwidthWowza;
		private var httpImpl:ServerClientBandwidthHttp;
		private var fmsImpl:ServerClientBandwidthFms;
		private var red5Impl:ServerClientBandwidthRed5;
		private var _bandwidthDetection:IBandwidthDetection;
		
		public function ServerClientBandwidthFactory(method:String = "http") {
			var bandwidthDetectionCls:Class = FactoryMethodUtil.getFactoryMethod("org.flowplayer.bwcheck.detect.servers.ServerClientBandwidth", method);
			_bandwidthDetection = new bandwidthDetectionCls();
			
			if (_bandwidthDetection == null) _bandwidthDetection = new ServerClientBandwidthHttp();
		}

		public function set url(url:String):void {
			_bandwidthDetection.url = url;
		}

		public function set service(service:String):void {
			_bandwidthDetection.service = service;
		}

		public function set connection(connect:NetConnection):void {
			_bandwidthDetection.connection = connect;
            connect.client = _bandwidthDetection;
		}

		public function start():void {
			_bandwidthDetection.start();
		}

		public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int = 0,useWeakReference:Boolean = false):void {
			_bandwidthDetection.addEventListener(type, listener);
		}

	}
}
