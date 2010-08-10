/* * This file is part of Flowplayer, http://flowplayer.org * * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.bwcheck {    import de.betriebsraum.video.BufferCalculator;    import flash.display.DisplayObject;    import flash.display.Sprite;    import flash.events.NetStatusEvent;    import flash.net.NetConnection;    import flash.net.NetStream;	import flash.net.NetStreamPlayOptions;	import flash.net.NetStreamPlayTransitions;    import flash.utils.Timer;		import org.flowplayer.ui.AutoHide;	    import org.flowplayer.bwcheck.detect.servers.ServerClientBandwidthFactory;    import org.flowplayer.bwcheck.event.DynamicStreamEvent;    import org.flowplayer.bwcheck.model.BitrateItem;    import org.flowplayer.bwcheck.monitor.QosMonitor;    import org.flowplayer.bwcheck.strategy.StreamSelectionFactory;    import org.flowplayer.cluster.RTMPCluster;    import org.flowplayer.controller.ClipURLResolver;    import org.flowplayer.controller.StreamProvider;    import org.flowplayer.model.Clip;    import org.flowplayer.model.ClipEvent;    import org.flowplayer.model.ClipType;    import org.flowplayer.model.PlayerEvent;    import org.flowplayer.model.Plugin;    import org.flowplayer.model.PluginEventType;    import org.flowplayer.model.PluginModel;    import org.flowplayer.util.Log;    import org.flowplayer.util.PropertyBinder;    import org.flowplayer.view.Flowplayer;    import org.flowplayer.view.AbstractSprite;    import org.red5.flash.bwcheck.IBandwidthDetection;    import org.red5.flash.bwcheck.events.BandwidthDetectEvent;        /**	 * @author danielr	 */	public class BitrateProvider extends AbstractSprite  implements ClipURLResolver, Plugin  {		private var _config:Config;		//private var log:Log = new Log(this);		private var _connection:NetConnection;		private var _netStream:NetStream;		private var _resolveSuccessListener:Function;		private var _failureListener:Function;		private var _clip:Clip;		private var _hasDetectedBW:Boolean = false;		protected var _infoTimer:Timer;		private var _start:Number = 0;        private var _model:PluginModel;        protected var _rtmpCluster:RTMPCluster;        protected var _qosMonitor:QosMonitor;        protected var _host:String;        protected var _previousStreamName:String;        private var _player:Flowplayer;        private var _resolving:Boolean;        private var _currentBitrateItem:BitrateItem;        private var _initFailed:Boolean;        private var _playButton:DisplayObject;        private var _isDynamic:Boolean;        private var _enableQosMonitor:Boolean;        private var _provider:StreamProvider;        private var _dynamicStreamName:String;        private var _dynamicOldStreamName:String;        private var _dynamicBitrateItem:BitrateItem;        private var _bitrateStorage:BitrateStorage;        private var _streamSelection:StreamSelectionFactory;        private var _detector:ServerClientBandwidthFactory;        private var _iconBar:IconBar;        private var _panelContainer:Sprite;        private var _autoHide:AutoHide;        private var _hdIndex:Number;        private var _hasHD:Boolean;        public function onConfig(model:PluginModel):void {        	            log.debug("onConfig(_)");            _config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;            _model = model;            _bitrateStorage = new BitrateStorage(_config.bitrateProfileName,"/");            _bitrateStorage.expiry = _config.cacheExpiry;			//_checkingOnBegin = _config.checkOnStart;            _isDynamic = _config.dynamic;            _enableQosMonitor = _config.enableQosMonitor;            _streamSelection = new StreamSelectionFactory(_config);                        log.debug("onConfig(), dynamic " + _isDynamic);            if ((_isDynamic && _config.checkOnStart) || _config.checkOnStart)            {	            try {	                _rtmpCluster = new RTMPCluster(_config);	                _rtmpCluster.onFailed(onFailed);	            } catch (e:Error) {	               // model.dispatchError(PluginError.INIT_FAILED, e.message);	                _initFailed = true;	            }            }        }        private function applyForClip(clip:Clip):Boolean {            log.debug("applyForClip(), clip.urlResolvers == " + clip.urlResolvers);            if (clip.urlResolvers == null) return false;            var apply:Boolean = clip.urlResolvers.indexOf(_model.name) >= 0;            log.debug("applyForClip? " + apply);            return apply;        }        public function onLoad(player:Flowplayer):void {            log.debug("onLoad()");            //if (_initFailed) return;            _player = player;						//createIconBar();            //_player.onLoad(onPlayerLoad);                        if (_config.streamSelectionFullScreen) {	            _player.onFullscreen(onFullscreen);	            _player.onFullscreenExit(onFullscreen);	        }            		            _player.playlist.onBeforeBegin(function(event:ClipEvent):void {                 var clip:Clip = event.target as Clip;                if (clip.getCustomProperty("bitrates") != null) buildBitrateList(clip);                      }, applyForClip);                      _player.playlist.onStart( function(event:ClipEvent):void {                log.debug("onStart() dynamic " + _isDynamic + " qosMonitor " + _qosMonitor );                var clip:Clip = event.target as Clip;                      if (clip.type != ClipType.IMAGE) {                		                init(clip.getNetStream(), clip);	                if (_isDynamic && ! _qosMonitor || _enableQosMonitor) {	                    initQosMonitor();	                }	            }            }, applyForClip);                        _player.playlist.onFinish( function(event:ClipEvent):void {            	destroyQosMonitor();            });                                                _model.dispatchOnLoad();        }        private function onFullscreen(event:PlayerEvent):void {            if (_player.streamProvider.type == "http") {                log.debug("onFullscreen(), doing progressive download and will not detect again on fullscreen");                return;            }            if (_config.dynamic) {                log.debug("onFullscreen(), dynamic enabled and we let QOS to switch to larger dimensions if BW available");                return;            }            checkBandwidthIfNotDetectedYet();        }        private function alreadyResolved(clip:Clip):Boolean {            return clip.getCustomProperty("bwcheckResolvedUrl") != null;        }        protected function hasDetectedBW():Boolean {            if (! _config.rememberBitrate) return false;            if (_hasDetectedBW) return true;			if (isRememberedBitrateValid()) return true;			return false;		}		public function set onFailure(listener:Function):void {			_failureListener = listener;		}						protected function onFailed(event:ClipEvent = null):void		{			log.info("Connections failed");            dispatch("onFailed");		}        private function dispatch(event:String):void {            _model.dispatch(PluginEventType.PLUGIN_EVENT, event, _rtmpCluster.currentHost, _rtmpCluster.currentHostIndex);        }				/**		 * Start the bandwidth check connection depending on the serverType.		 * By default the FMS implementation requires a true property to the first of the connection arguments.		 * The other server implementations don't require this as they use AMF service callback methods.		 */		public function doBWConnect():void		{			_connection = new NetConnection();			_connection.addEventListener(NetStatusEvent.NET_STATUS, _onConnectionStatus);            _connection.client = new NullNetConnectionClient();                        _host = _rtmpCluster.nextHost;            if (! _host) {            	log.error("no live hosts to connect to");                useDefaultBitrate();                //_model.dispatchError(PluginError.ERROR, "no live hosts to connect to");                return;            }                        log.debug("doBWConnect() " + _host.slice(-5, _host.length).toLowerCase());            // set a listener to be used if connection fails, will connect to another host in the cluster            _rtmpCluster.onReconnected(onRTMPReconnect);            _rtmpCluster.start();            log.debug("_doBwConnect(), connecting to " + _host);            dispatch("onConnect");            _detector = new ServerClientBandwidthFactory(_config.serverType);            _detector.addEventListener(BandwidthDetectEvent.DETECT_COMPLETE, onServerClientComplete);            _detector.addEventListener(BandwidthDetectEvent.DETECT_STATUS, onServerClientStatus);            _detector.addEventListener(BandwidthDetectEvent.DETECT_FAILED, onDetectFailed);            _detector.connection = _connection;            _detector.url = _host;            log.debug("serverType is " + _config.serverType);            switch(_config.serverType)                    {                case "fms":                    _connection.connect(_host, true);                    break;                case "wowza":                    _connection.connect(_host, true);                    break;                case "red5":                    _connection.connect(_host);                    break;                case "http":                    _connection.connect(null);                    break;                default:                    _connection.connect(null);                    break;            }        }		public function handeNetStatusEvent(event:NetStatusEvent):Boolean		{			return true;		}				protected function _onConnectionStatus(event:NetStatusEvent):void {            if (hasDetectedBW()) return;			            switch (event.info.code)            {                case "NetConnection.Connect.Success":                    log.info("successfully connected to " + _connection.uri);                    _rtmpCluster.stop();                    doDetection();                    break;                //connection has failed, reattempt using the fallback system                case "NetConnection.Connect.Failed":                    log.info("Couldn't connect to " + _connection.uri);                    _rtmpCluster.setFailedServer(_connection.uri);                    _rtmpCluster.stop();                    doBWConnect();                    break;                //connection has closed                case "NetConnection.Connect.Closed":            }		}					/**		 * Determine the server type to choose which way to handle the bandwidth detection and run the detection.		 */		protected function doDetection():void		{            if (_config.serverType != "fms" && _config.serverType != "wowza") {                _detector.start();            }		}				/**		 * Called when a detection has failed		 */		public function onDetectFailed(event:BandwidthDetectEvent):void		{			event.stopPropagation();			log.error("\n Detection failed with error: " + event.info.application + " " + event.info.description);		}				/**		 * Called when a detection has completed and set the bandwidth properties from the returned values		 */		 		public function onServerClientComplete(event:BandwidthDetectEvent):void		{			event.stopPropagation();			log.info("\n\n kbit Down: " + event.info.kbitDown + " Delta Down: " + event.info.deltaDown + " Delta Time: " + event.info.deltaTime + " Latency: " + event.info.latency);			_hasDetectedBW = true;						// Set the detected bandwidth			var bandwidth:Number = event.info.kbitDown;			var mappedBitrate:BitrateItem = getMappedBitrate(bandwidth);			log.debug("bandwidth (kbitDown) " + bandwidth);			log.info("mapped to bitrate " + mappedBitrate.bitrate);			// Store the bitrate to prevent further bitrate detections			rememberBandwidth(bandwidth);            			_connection.close();            onBandwidthDetected(mappedBitrate, bandwidth);        }        private function get bitrateItems():Array {            return _player.playlist.current.getCustomProperty("bitrateItems") as Array;        }        private function getMappedBitrate(bandwidth:Number = -1):BitrateItem {			if (bandwidth == -1) return _streamSelection.getDefaultStream(bitrateItems, _player) as BitrateItem;			return _streamSelection.getStream(bandwidth, bitrateItems, _player) as BitrateItem;        }                private function getMappedBitrateFromIndex(index:Number):BitrateItem {			return _streamSelection.getStream( bitrateItems[index].bitrate, bitrateItems, _player) as BitrateItem;        }                private function useDefaultBitrate():void {        	log.info("using default bitrate because of an error with the bandwidth check");            onBandwidthDetected(getMappedBitrate(), -1);        }        private function onBandwidthDetected(mappedBitrate:BitrateItem, detectedBitrate:Number = -1):void {            log.debug("onBandwidthDetected()");            _currentBitrateItem = mappedBitrate;                        dynamicBuffering(mappedBitrate.bitrate, detectedBitrate);                        if (_playButton && _playButton.hasOwnProperty("stopBuffering")) {                _playButton["stopBuffering"]();            }            // check if we are resolving or just switching streams based on detected BW           /* if (_checkingOnBegin) {                log.debug("onBandwidthDetected(), checkOnBegin is true, about to set resolved URL and call play");                changeStreamNames(mappedBitrate);                _checkingOnBegin = false;                log.debug("dispatching onBwDone, mapped bitrate: " + mappedBitrate + " detected bitrate " + detectedBitrate + " url: " + _clip.url);                _model.dispatch(PluginEventType.PLUGIN_EVENT, "onBwDone", mappedBitrate, detectedBitrate);                if (_bufferingOnly) {                    _player.startBuffering();                                    } else {                    _player.play();                }                return;            } else*/ if (_resolving) {                changeStreamNames(mappedBitrate);                _resolveSuccessListener(_clip);                _resolving = false;            } else if (_netStream && (_player.isPlaying() || _player.isPaused())) {                switchStream(mappedBitrate);                            } else {                changeStreamNames(mappedBitrate);            }            log.debug("dispatching onBwDone, mapped bitrate: " + mappedBitrate.bitrate + " detected bitrate " + detectedBitrate + " url: " + _clip.url);            _model.dispatch(PluginEventType.PLUGIN_EVENT, "onBwDone", mappedBitrate, detectedBitrate);        }        private function changeStreamNames(mappedBitrate:BitrateItem):void {            _previousStreamName = _clip.url;            var url:String = getClipUrl(_clip, mappedBitrate);            _clip.setResolvedUrl(this, url);            _clip.setCustomProperty("bwcheckResolvedUrl", url);            _clip.setCustomProperty("mappedBitrate", mappedBitrate);            log.debug("mappedUrl " + url + ", clip.url now " + _clip.url);        }        private function switchStream(mappedBitrate:BitrateItem):void {            _currentBitrateItem = mappedBitrate;                        log.debug("switchStream");            changeStreamNames(mappedBitrate);            if (_netStream && _netStream.hasOwnProperty("play2") && _config.dynamic) {                switchStreamDynamic(mappedBitrate);            } else {                log.debug("calling switchStream");                 _model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitch", mappedBitrate, _clip.url,  _previousStreamName);				_player.switchStream(_clip);        	 }        }        private function onDynamicStreamStatus(event:NetStatusEvent):void        {        	switch (event.info.code)        	{        		case "NetStream.Play.Transition":        			        			if (_qosMonitor) {                		_qosMonitor.currentStreamId = _currentBitrateItem.index;            		}        			_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onDynamicStreamStatus);        			_model.dispatch(PluginEventType.PLUGIN_EVENT, "onStreamSwitch", _dynamicBitrateItem, event.info.details,  _dynamicOldStreamName);        		break;        	}        }        private function switchStreamDynamic(bitrate:BitrateItem):void {            _netStream.addEventListener(NetStatusEvent.NET_STATUS, onDynamicStreamStatus);            log.debug("doing a dynamic switch");            var options:NetStreamPlayOptions = new NetStreamPlayOptions();            if (_previousStreamName) {                options.oldStreamName = _previousStreamName;                options.transition = NetStreamPlayTransitions.SWITCH;            } else {                options.transition = NetStreamPlayTransitions.RESET;            }            options.streamName = _clip.url;                        _dynamicStreamName = options.streamName;            _dynamicOldStreamName = options.oldStreamName;            _dynamicBitrateItem = bitrate;            log.debug("calling switchStream with Dynamic Switch Streaming, stream name is " + options.streamName);            //_player.switchStream(_clip, options);			_netStream.play2(options);		}						/**		 * Called during the bitrate detection checking and return its status		 */		public function onServerClientStatus(event:BandwidthDetectEvent):void		{				if (event.info) {				log.info("\n count: "+event.info.count+ " sent: "+event.info.sent+" timePassed: "+event.info.timePassed+" latency: "+event.info.latency+" cumLatency: " + event.info.cumLatency);				//dispatchEvent(new ClipEvent(BWDetectEventType.DETECT_STATUS));			}		}				protected function onRTMPReconnect():void		{            dispatch("onConnectFailed");            _rtmpCluster.setFailedServer(_host);            _connection.close();            doBWConnect();			log.info("Attempting reconnection");		}				protected function buildBitrateList(clip:Clip):void {            if (! clip.getCustomProperty("bitrates")) {                return;            }			var items:Array = new Array();			for each(var props:Object in clip.getCustomProperty("bitrates")) {				var bitrate:BitrateItem = new BitrateItem();				for (var key:String in props) {					//if custom properties are set ignore them.                     if (bitrate.hasOwnProperty(key)) bitrate[key] = props[key];				}				items.push(bitrate);			}						//put the highest bitrate at the top			items.sortOn("bitrate", Array.DESCENDING | Array.NUMERIC);            for (var i:int = 0; i < items.length; i++) {                var prop:BitrateItem = items[i];                log.debug("bitrate ID " + i + ": "+ prop.bitrate + ": " + prop.url + ", width: " + prop.width);                // initialize the index value                prop.index = i;                if (prop.hd) {                	_hasHD = true;                	_hdIndex = i;                }            }            clip.setCustomProperty("bitrateItems", items);		}						/**		 * Store the detection and chosen bitrate if the rememberBitrate config property is set.		 */		protected function rememberBandwidth(bw:int):void {			if (_config.rememberBitrate) {                _bitrateStorage.bandwidth = bw;                log.debug("stored bandwidth " + bw);            }		}        private function isRememberedBitrateValid():Boolean {            log.debug("isRememberedBitrateValid()");            if (! _bitrateStorage.bandwidth) {                log.debug("bandwidth not in SO");                return false;            }			            var expired:Boolean = _bitrateStorage.isExpired;            log.debug("is remembered bitrate expired?: " + expired + (expired ? ", age is " + _bitrateStorage.age : ""));                  return ! expired;        }        /**         * Callback from QOS Monitor.         * @param event         * @return         */        protected function onSwitchStream(event:DynamicStreamEvent):void		{			var mappedBitrate:BitrateItem = getMappedBitrateFromIndex(event.info.streamID);			rememberBandwidth(event.info.maxBandwidth);						dynamicBuffering(mappedBitrate.bitrate, event.info.maxBandwidth);			switchStream(mappedBitrate);		}				public function resolve(provider:StreamProvider, clip:Clip, successListener:Function):void {            log.debug("resolve " + clip);						if (clip.getCustomProperty("bitrates") == null)            {            	log.debug("Bitrates configuration not enabled for this clip");            	successListener(clip);                return;            }                        if (alreadyResolved(clip)) {                log.debug("resolve(): bandwidth already resolved for clip " + clip + ", will not detect again");                successListener(clip);                return;            }                                   _provider = provider;            _resolving = true;            _resolveSuccessListener = successListener;            init(provider.netStream, clip);            checkBandwidthIfNotDetectedYet();        }        				private function dynamicBuffering(mappedBitrate:Number, detectedBitrate:Number):void		{			if (_config.enableDynamicBuffer)			{				_clip.onMetaData(function(event:ClipEvent):void {					_clip.bufferLength = BufferCalculator.calculate(_clip.metaData.duration, mappedBitrate, detectedBitrate);						log.debug("Dynamically setting buffer time to " + _clip.bufferLength + "s");				});							}		}        private function checkBandwidthIfNotDetectedYet():void {            if (! applyForClip(_player.playlist.current)) return;            if (hasDetectedBW()) {                var mappedBitrate:BitrateItem = getMappedBitrate(_bitrateStorage.bandwidth);                log.info("using remembered bandwidth " + _bitrateStorage.bandwidth + ", maps to bitrate " + mappedBitrate.bitrate);                onBandwidthDetected(mappedBitrate, _bitrateStorage.bandwidth);            } else if (_initFailed) {            	useDefaultBitrate();            } else if (_isDynamic && !_config.checkOnStart) {            	log.info("using dynamic switching with default bitrate ");            	onBandwidthDetected(getMappedBitrate(), -1);            } else if (_config.checkOnStart) {                log.debug("not using remembered bandwidth, detecting now");                doBWConnect();            }        }        private function init(netStream:NetStream, clip:Clip):void {            _netStream = netStream;            _clip = clip;            _start = netStream ? netStream.time : 0;                        buildBitrateList(clip);            //createIconBar();            //initAutoHide();        }        private function initQosMonitor():void {            import org.flowplayer.bwcheck.monitor.RTMPQosMonitor;            log.debug("initQosMonitor(): starting dynamic bitrate adaptation with quality of service monitoring");            if (_qosMonitor) {                throw new Error("already running dynamic bitrate adaptation!");            }            _isDynamic = true;                        //if (isHTTP())            //{            //	import org.flowplayer.bwcheck.monitor.HTTPQosMonitor;            	            //	_qosMonitor = new HTTPQosMonitor(_config);            //} else {            	_qosMonitor = new RTMPQosMonitor(_config);            //}            _qosMonitor.bitrateProperties = bitrateItems;            _qosMonitor.bitrateStorage = _bitrateStorage;            _qosMonitor.addEventListener(DynamicStreamEvent.SWITCH_STREAM, onSwitchStream);            _qosMonitor.netStream = _netStream;            _qosMonitor.currentStreamId = _currentBitrateItem.index;            _clip.onStart(_qosMonitor.onStart);            _clip.onStop(_qosMonitor.onStop);            _clip.onBufferEmpty(_qosMonitor.onBufferEmpty);            _clip.onBufferFull(_qosMonitor.onBufferFull);            _clip.onSeek(_qosMonitor.onSeek);            _clip.onPause(_qosMonitor.onPause);            _clip.onResume(_qosMonitor.onResume);            _clip.onError(_qosMonitor.onError);            _qosMonitor.start();        }        private function destroyQosMonitor():void {            log.debug("destroyDynamicStream()");            if (! _qosMonitor) return;            if (!  _clip) return;            _isDynamic = false;            log.debug("destroyDynamicStream(): disabling dynamic bitrate adaptation");            _qosMonitor.removeEventListener(DynamicStreamEvent.SWITCH_STREAM, onSwitchStream);            _clip.unbind(_qosMonitor.onStart);            _clip.unbind(_qosMonitor.onStop);            _clip.unbind(_qosMonitor.onBufferEmpty);            _clip.unbind(_qosMonitor.onBufferFull);            _clip.unbind(_qosMonitor.onSeek);            _clip.unbind(_qosMonitor.onPause);            _clip.unbind(_qosMonitor.onResume);            _clip.unbind(_qosMonitor.onError);            _qosMonitor.stop();            _qosMonitor = null;		}		protected function  getClipUrl(clip:Clip, mappedBitrate:BitrateItem):String		{			log.info("Resolved stream url: " + mappedBitrate.url);			return mappedBitrate.url;			//return (clip.baseUrl ? URLUtil.completeURL(clip.baseUrl, mappedBitrate.url) : mappedBitrate.url);		}        private function checkCurrentClip():Boolean {            var clip:Clip = _player.playlist.current;            if (_clip == clip) return true;                        if (clip.urlResolvers && clip.urlResolvers.indexOf(_model.name) < 0) {                return false;            }            _clip = clip;            return true;        }              private function initAutoHide():void {        	_autoHide = new AutoHide(null, _config.autoHide, _player, stage, _iconBar);            _autoHide.hide();            _autoHide.onShow(onButtonsShow);            _autoHide.start();        }                private function onPlayerLoad(event:PlayerEvent):void {        	_autoHide = new AutoHide(null, _config.autoHide, _player, stage, _iconBar);            _autoHide.hide();            _autoHide.onShow(onButtonsShow);            _autoHide.start();        }                private function createIconBar():void {            _iconBar = new IconBar(_config, _player, _hasHD);            _iconBar.onHd(function(isHD:Boolean):void {                //log.error(isHD.toString());            });                    }                private function onButtonsShow():Boolean {        	return _hasHD;        	//return _hdIndex > 0;            //return ! this.visible || this.alpha == 0;        }        [External]        public function checkBandwidth():void    	{            log.debug("checkBandwidth");            if (! checkCurrentClip()) return;            _start = _provider ? _provider.time : 0;            _hasDetectedBW = false;            _bitrateStorage.clear();            doBWConnect();        }        		[External]		public function setBitrate(bitrate:Number):void		{            log.debug("set bitrate()");            if (! checkCurrentClip()) return;            try {                if (_player.isPlaying() || _player.isPaused()) {                    switchStream(getMappedBitrate(bitrate));                    destroyQosMonitor();                }            } catch (e:Error) {                log.error("error when switching streams " + e);            }		}        [External]        public function enableDynamic(enabled:Boolean):void {            log.debug("set dynamic(), currently " + _isDynamic +  ", new value" + enabled);            if (_isDynamic == enabled) return;                        if (enabled) {                initQosMonitor();            } else {                destroyQosMonitor();            }        }                [External]        public function get labels():Object {            if (! bitrateItems) {                buildBitrateList(_player.playlist.current);            }            var labels:Object = {};            for (var i:int = 0; i < bitrateItems.length; i++) {                var item:BitrateItem = bitrateItems[i];                if (item.label) {                    labels[item.bitrate] = item.label;                }            }        	return labels;        }                [External]        public function getSelectionStrategy():String {        	return _config.streamSelectionStrategy;        }        [External]        public function get bitrate():Number {            log.debug("get bitrate()");            if (! checkCurrentClip()) return undefined;            if (_config.rememberBitrate && _bitrateStorage.bandwidth >= 0) {                log.debug("get bitrate(), returning remembered bandwidth");                var mappedBitrate:BitrateItem = getMappedBitrate(_bitrateStorage.bandwidth);                return mappedBitrate.bitrate;            }                        log.debug("get bitrate(), returning current bitrate");            return _currentBitrateItem.bitrate;        }        public function getDefaultConfig():Object {            return null;        }    }}