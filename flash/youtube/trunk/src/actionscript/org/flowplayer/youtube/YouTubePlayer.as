package org.flowplayer.youtube {

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.system.Security;
    import flash.events.IOErrorEvent;
    import flash.display.Loader;
    import flash.net.URLRequest;
    
    import org.flowplayer.youtube.events.YouTubeEvent;
    

    public class YouTubePlayer extends EventDispatcher {
        
        private var _youTubePlayer:Object;
        private var _youTubePlayerLoader:Loader;
        private var _apiURL:String;

        public function YouTubePlayer(apiURL:String) {
            super(null);
            _apiURL = apiURL;
        }
        
        public function load():void 
        {
            Security.allowInsecureDomain("*");
            Security.allowDomain("*");
            Security.allowDomain("www.youtube.com");
            _youTubePlayerLoader = new Loader();
            _youTubePlayerLoader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit, false, 0, true);
            _youTubePlayerLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _youTubePlayerLoader.load(new URLRequest(_apiURL));
        }
        
        /**
         * Loader Methods
         */
        
        public function cueVideoById(videoId:String, startSeconds:Number=0, suggestedQuality:String="default"):void
        {
            _youTubePlayer.cueVideoById(videoId, startSeconds, suggestedQuality);
        }
   
        public function loadVideoById(videoId:String, startSeconds:Number=0, suggestedQuality:String="default"):void
        {
            _youTubePlayer.loadVideoById(videoId, startSeconds, suggestedQuality);
        }
      
        public function cueVideoByUrl(mediaContentUrl:String, startSeconds:Number=0):void
        {
            _youTubePlayer.cueVideoByUrl(mediaContentUrl, startSeconds);
        }
        
        public function loadVideoByUrl(mediaContentUrl:String, startSeconds:Number=0):void
        {
            _youTubePlayer.loadVideoByUrl(mediaContentUrl, startSeconds);
        }
        
        /**
         * Status Methods Read-Only
         */
  
        public function get videoBytesLoaded():Number
        {
        	if (!_youTubePlayer) return 0;
            return _youTubePlayer.getVideoBytesLoaded();
        }
    
        public function get videoBytesTotal():Number
        {
        	if (!_youTubePlayer) return 0;
            return _youTubePlayer.getVideoBytesTotal();
        }
        
        public function get videoStartBytes():Number
        {
            if (!_youTubePlayer) return 0;
            return _youTubePlayer.getVideoStartBytes();
        }
     
        public function get playerState():Number
        {
            return _youTubePlayer.getPlayerState();
        }
    
        public function get currentTime():Number
        {
            //if (this.isInit()) return 0;
            return _youTubePlayer.getCurrentTime();
        }
        
        public function get duration():Number
        {
            return _youTubePlayer.getDuration();
        }
       
        public function get videoUrl():String
        {
            return _youTubePlayer.getVideoUrl();
        }
       
        public function get embedCode():String
        {
            return _youTubePlayer.getVideoEmbedCode();
        }
        
        public function get availableQualityLevels():Array {
        	return _youTubePlayer.getAvailableQualityLevels();
        }
        
        /**
         * Property Getters / Setters
         */
        
  
        public function get playbackQuality():String
        {
            return _youTubePlayer.getPlaybackQuality();
        }

        public function set playbackQuality(suggestedQuality:String):void
        {
            _youTubePlayer.setPlaybackQuality(suggestedQuality);
        }
        
        public function get volume():Number
        {
         	return _youTubePlayer.getVolume();
        }
        
        public function setVolume(inVolume:Number):void
        {
            _youTubePlayer.setVolume(inVolume);
        }
        
        public function setSize(inWidth:Number, inHeight:Number):void
        {
            _youTubePlayer.setSize(inWidth, inHeight);
        }
        
        /**
         * Playback Methods
         */
      
        public function playVideo():void
        {
            _youTubePlayer.playVideo();
        }
       
        public function pauseVideo():void
        {
            _youTubePlayer.pauseVideo();
        }
       
        public function stopVideo():void
        {
            _youTubePlayer.stopVideo();
        }
        
        public function seekTo(seconds:Number, allowSeekAhead:Boolean):void
        {
            _youTubePlayer.seekTo(seconds, allowSeekAhead);
        }
       
        public function mute():void
        {
            _youTubePlayer.mute();
        }
   
        public function unMute():void
        {
            _youTubePlayer.unMute();
        }
        
        public function isMuted():Boolean
        {
            return _youTubePlayer.isMuted();
        }
        
        public function destroy():void
        {
            _youTubePlayer.destroy();
        }
        
        public function isEnded():void {
        	this.playerState == 0;	
        }
        
        public function isPlaying():void {
        	this.playerState == 1;	
        }
        
        public function isPaused():void {
        	this.playerState == 2;	
        }
        
        public function isBuffering():void {
        	this.playerState == 3;	
        }
        
        public function isCued():void {
        	this.playerState == 5;	
        }
        
        public function isInit():void {
        	this.playerState == -1;	
        }
        

        private function onLoaderInit(event:Event):void {
            
            var player:Loader = Loader(event.target.loader);
            _youTubePlayer = player.content;
            _youTubePlayer.addEventListener("onReady", onPlayerReady);
            _youTubePlayer.addEventListener("onError", onPlayerError);
            _youTubePlayer.addEventListener("onStateChange", onPlayerStateChange);
            _youTubePlayer.addEventListener("onPlaybackQualityChange", onVideoPlaybackQualityChange);
            _youTubePlayerLoader.contentLoaderInfo.removeEventListener(Event.INIT, onLoaderInit);
            _youTubePlayerLoader = null;
   
        }
           
        private function ioErrorHandler(event:IOErrorEvent):void {
            dispatchEvent(new YouTubeEvent(YouTubeEvent.IOERROR,event));
        }
        
        private function onPlayerReady(event:Event):void {
            dispatchEvent(new YouTubeEvent(YouTubeEvent.READY,Object(event).data));
        }

        private function onPlayerError(event:Event):void {
            dispatchEvent(new YouTubeEvent(YouTubeEvent.ERROR,Object(event).data));
        }

        private function onPlayerStateChange(event:Event):void {
            dispatchEvent(new YouTubeEvent(YouTubeEvent.STATE_CHANGE,Object(event).data));
        }

        private function onVideoPlaybackQualityChange(event:Event):void {
            dispatchEvent(new YouTubeEvent(YouTubeEvent.QUALITY_CHANGED,Object(event).data));
        }
        
        public function get content():Object {
        	return _youTubePlayer;
        }

    }

}
