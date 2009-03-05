package org.flowplayer.cluster
{
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.utils.URLUtil;
	
	import com.as3collections.collections.ArrayCollection;
	
	import org.flowplayer.flow_internal;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipEventDispatcher;
	import org.flowplayer.cluster.event.RTMPEventType;
	
	use namespace flow_internal;
	
	public class RTMPCluster extends ClipEventDispatcher
	{
		protected var _hosts:Array;
		protected var _netConnectionUrl:*;
		protected var _timer:Timer;
		protected var _hostIndex:int = 0;
		protected var _hostCount:int = 0;
		protected var _connectCount:int = 0;
		protected var _reConnectCount:int = 0;
		protected var _connectTimeout:int = 3000;
		protected var _loadBalanceServers:Boolean = false;
		protected var _liveServers:Array;
		protected var _liveRandomServers:Array = [];
		private var _startAfterConnect:Boolean;
		protected var _failureExpiry:int = 0;
		private var _config:*;
		
		
		public function RTMPCluster(config:*)
		{
			_config = config;
			hosts = _config.hosts;
			_netConnectionUrl = config.netConnectionUrl;
			_connectCount = config.connectCount;
			_connectTimeout = config.connectTimeout;
			_failureExpiry = config.failureExpiry;
			
			//_provider = provider
		}
		
		public function onReconnected(listener:Function):void {
			setListener(RTMPEventType.RECONNECTED, listener);
		}
		
		public function onFailed(listener:Function):void {
			setListener(RTMPEventType.FAILED, listener);
		}
		
		/*
		public function set netConnectionUrl(url:*):void
		{
			_netConnectionUrl = url;
		}
		
		public function get netConnectionUrl():*
		{
			return _netConnectionUrl;
		}
		*/
		
		public function set hosts(hosts:Array):void
		{
			_hosts = hosts;	
			_liveServers = currentHosts;
		}
		
		public function get currentHosts():Array
		{
			return _hosts.filter(_checkLiveHost);
		}
		
		public function get hosts():Array
		{
			return _hosts;
			//return _hosts.filter(_checkLiveHost);
		}
		
		public function set loadBalanceServers(loadBalanceServers:Boolean):void
		{
			_loadBalanceServers	= loadBalanceServers;
		}
		
		/*
		public function set connectTimeout(timeout:Number):void
		{
			_connectTimeout = timeout;
		}*/
		
		public function get host():*
		{
			if (_loadBalanceServers && hasMultipleHosts())
			{
				var index:uint = getRandomIndex();
				_hostIndex = index;
				return _liveServers[_hostIndex];
				//return getHost(index);
			} else if (hasMultipleHosts()) {
				//_hostIndex = 0;
				// If we have multiple live hosts
				return _liveServers[_hostIndex];
				//return getHost(_hostIndex);
			}
			
			return _netConnectionUrl;
		}
		
		public function start():void
		{
			_timer = new Timer(_connectTimeout, _liveServers.length);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE , tryFallBack);
			if (!_timer.running && hasMultipleHosts())
			{
				_timer.start();
			}
		}
		
		public function stop():void
		{
			if (_timer.running) _timer.stop();
		}
		
		public function hasMultipleHosts():Boolean
		{
			return _liveServers.length > 0;
		}
		
		public function getRandomIndex():uint
		{
			return Math.round(Math.random() * (_liveServers.length - 1));
		}
		
		public function get liveServers():Array
		{
			return _liveServers;
		}
		
		private function _checkLiveHost(element:*, index:int, arr:Array):Boolean
		{
			return _isLiveServer(element);
		}
		
		private function _getFailedServerSO(host:String):SharedObject
		{
			var domain:String = URLUtil.getServerName(host);
			return SharedObject.getLocal(domain,"/");
		}
		
		public function setFailedServer(host:String):void
		{
			 log.error("Setting Failed Server: " + host);
			 var server:SharedObject = _getFailedServerSO(host);
			 server.data.failureTimestamp = new Date();
		}
		
		public function set connectCount(count:Number):void
		{
			_connectCount = count;
		}
		
		protected function hasMoreHosts():Boolean
		{
			_hostIndex++;
			_liveServers = currentHosts;
			
	
			if (_hostIndex >= _liveServers.length)
			{ 
				//
				_reConnectCount++;
				if (_reConnectCount < _connectCount) 
				{
					log.error("Restarting Connection Attempts");
					_hostIndex = 0;
				}
			}
			log.error("Host Index: " + _hostIndex + " LiveServers: " + _liveServers.length);
			return (_hostIndex <= _liveServers.length && _liveServers[_hostIndex]);
		}
		
		private function _isLiveServer(host:String):Boolean
		{

			var server:SharedObject = _getFailedServerSO(host);
			// Server is failed, determine if the failure expiry interval has been reached and clear it
			if (server.data.failureTimestamp)
			{
				var date:Date = new Date();	
				
				// Determine the failure offset
				var offset:int = (date.getTime() - server.data.failureTimestamp.getTime()) / 60; 
				
				log.error("Failed Server Remaining Expiry: " + offset + " Start Time: " + server.data.failureTimestamp.getTime() + " Current Time: " + date.getTime());
				
				// Failure offset has reached the failureExpiry setting, clear it from the list to allow a connection
				if (offset >= _config.failureExpiry)
				{
					log.error("Clearing Failure Period " + _config.failureExpiry);
					server.clear();
					return true;
				} 
				return false;
			}
			return true;
		}
		
		protected function tryFallBack(e:TimerEvent):void
		{


			//netConnection.proxyType = "none";
			//log.info("Failed connection to " + netConnection.uri);
			
			// Set this server as failed to prevent reconnections to it
			//setFailedServer(netConnection.uri);
			
			// Check if there is more hosts to attempt reconnection to
			if (hasMoreHosts())
			{
				
				dispatchEvent(new ClipEvent(RTMPEventType.RECONNECTED));

			} else {
				// we have reached the end of the hosts list stop reconnection attempts and send a failed event
				stop();
				dispatchEvent(new ClipEvent(RTMPEventType.FAILED));
			}
		}
	}
	
	
}