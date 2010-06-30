package org.flowplayer.youtube {

	import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.system.Security;
    import flash.events.IOErrorEvent;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
	import flash.net.URLVariables;

	import org.flowplayer.youtube.events.YouTubeDataEvent;
	import org.flowplayer.youtube.model.Gdata;

	public class YouTubeData extends EventDispatcher {
		
        private var _youTubeDataLoader:URLLoader;
        private var _gdataApiURL:String;
        private var _gdataApiFormat:String;
        private var _gdataApiVersion:String;
        private var _gData:Gdata;
        
        private var atom:Namespace = new Namespace("http://www.w3.org/2005/Atom");
   		private var media:Namespace = new Namespace("http://search.yahoo.com/mrss/");
    	private var gd:Namespace = new Namespace("http://schemas.google.com/g/2005");
    	private var yt:Namespace = new Namespace("http://gdata.youtube.com/schemas/2007");
        
		public function YouTubeData(gdataApiURL:String, gdataApiVersion:String, gdataApiFormat:String) {
            super(null);
            _gdataApiURL = gdataApiURL;
            _gdataApiVersion = gdataApiVersion;
            _gdataApiFormat = gdataApiFormat;
            
        }
        
        public function load():void {
	    	_youTubeDataLoader = new URLLoader();
	      	_youTubeDataLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	      	_youTubeDataLoader.addEventListener(Event.COMPLETE, onLoaderComplete);
	      	
	      	var request:URLRequest = new URLRequest(_gdataApiURL);

	      	var urlVariables:URLVariables = new URLVariables();
	      	urlVariables.v = _gdataApiVersion;
	      	urlVariables.format = _gdataApiFormat;
	      	request.data = urlVariables;

	      	try {
	        	_youTubeDataLoader.load(request);
	      	} catch (error:SecurityError) {
	      		dispatchEvent(new YouTubeDataEvent(YouTubeDataEvent.IOERROR, "A SecurityError occurred while loading: " + request.url + " "  + error.message));
	      	}
	    }
	    
	    private function onLoaderComplete(event:Event):void {
	     	default xml namespace = atom;
	     	var atomData:String = _youTubeDataLoader.data;
	      	var atomXml:XML = new XML(atomData);
	
	      	var aspectRatios:XMLList = atomXml..*::aspectRatio;
	
	      	//_isWidescreen = aspectRatios.toString() == "widescreen";
			
			parseFeedData(atomXml);
    	}
    	
    	private function ioErrorHandler(event:IOErrorEvent):void {
            dispatchEvent(new YouTubeDataEvent(YouTubeDataEvent.IOERROR,event));
        }
    	
    	private function parseFeedData(atomXml:XML):void {
	    	_gData = new Gdata(); 
	    	_gData.tags = String(atomXml.media::group.media::keywords).split(",");
			_gData.category = String(atomXml.media::group.media::category.@label);
			_gData.title = String(atomXml.title);
			_gData.content = String(atomXml.media::group.media::description);
			_gData.author = {name: String(atomXml.author.name), uri: String(atomXml.author.uri)};	
			
			var thumbnails:Array = buildThumbnailsList(XMLList(atomXml.media::group.media::thumbnail));
			_gData.defaultThumbnail = String(thumbnails[thumbnails.length - 1].url);
			_gData.thumbnails = thumbnails;
			
			_gData.statistics = {favoriteCount: Number(atomXml.yt::statistics.@favoriteCount), viewCount: Number(atomXml.yt::statistics.@viewCount)};
			_gData.duration = Number(atomXml.media::group.yt::duration.@seconds);
			//_gData.bitrates = clip.getCustomProperty("bitrates") as Array;
			var links:XMLList = XMLList(atomXml.link);
			
			getRelatedVideos(links[2].@href);
		
    	}
    	
    	private function getRelatedVideos(url:String):void {
	    	//var relatedLoader:URLLoader = new URLLoader();
	    	_youTubeDataLoader.close();
	    	_youTubeDataLoader.removeEventListener(Event.COMPLETE, onLoaderComplete);
	      	_youTubeDataLoader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var relatedDataXML:XML = XML(_youTubeDataLoader.data);
				var entries:XMLList = XMLList(relatedDataXML.entry);
				
				_youTubeDataLoader.close();
				_youTubeDataLoader = null;
				
				_gData.relatedVideos = [];

				
					for each (var entry:XML in entries) {
						var id:String = String(entry.id).substring(String(entry.id).lastIndexOf(":") + 1, String(entry.id).length);
						var author:Object = {name: String(entry.author.name), uri: String(entry.author.uri)};
						
						var tags:Array = String(entry.media::group.media::keywords).split(",");
						
						var thumbnails:Array = buildThumbnailsList(XMLList(entry.media::group.media::thumbnail));
						var defaultThumbnail:String = (thumbnails.length > 0 ? thumbnails[thumbnails.length - 1].url : "");
				
						var ratings:Object = {average: Number(entry.gd::rating.@average), max: Number(entry.gd::rating.@max), min: Number(entry.gd::rating.@min), numRaters: Number(entry.gd::rating.@numRaters)};
						var statistics:Object = {favoriteCount: Number(entry.yt::statistics.@favoriteCount), viewCount: Number(entry.yt::statistics.@viewCount)};
						
						_gData.relatedVideos.push({url: "api:" + id, title: String(entry.title), content: String(entry.media::group.media::description), author: author, tags:tags, category: String(entry.media::group.media::category.@label), defaultThumbnail: defaultThumbnail, thumbnails: thumbnails, duration: Number(entry.media::group.yt::duration.@seconds), ratings: ratings, statistics: statistics});
						
					}

					dispatchEvent(new YouTubeDataEvent(YouTubeDataEvent.ON_DATA, _gData));
			
			});
	      	_youTubeDataLoader.load(new URLRequest(url));	
	    }
	    
	    private function buildThumbnailsList(thumbnailList:XMLList):Array {
	    	var thumbnails:Array = [];
	
			for each (var thumbnail:Object in thumbnailList) {
				
				thumbnails.push({url: String(thumbnail.@url), height: Number(thumbnail.@height), width: Number(thumbnail.@width), time: String(thumbnail.@time)});
			}
			
			return thumbnails;
	    }
	}
}
