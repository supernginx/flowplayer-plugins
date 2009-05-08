package org.flowplayer.related {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import org.flowplayer.controller.ResourceLoader;
	import org.flowplayer.model.PlayerError;
	import org.flowplayer.util.Log;
	import org.flowplayer.view.ErrorHandler;
	import org.flowplayer.view.Flowplayer;
	
	public class CoverFlow extends EventDispatcher implements ErrorHandler
    {
    	private var _coverFlowData:Array;
    	private var _imageWidth:Number;
    	private var _imageHeight:Number;
    	private var _currentIndex:Number = 0;
    	private var _currentImageIndex:Number = 0;
    	private var _parent:Sprite;
    	private var log:Log = new Log(this);
    	private var _loader:ResourceLoader;
    	private var _player:Flowplayer;
    	private var _container:Sprite;
    	private var _images:Array = new Array();

    	
    	public function CoverFlow(parent:Sprite, coverFlowData:Array, imageWidth:Number, imageHeight:Number, player:Flowplayer):void
    	{
    		_coverFlowData = coverFlowData;
    		_imageWidth = imageWidth;
    		_imageHeight = imageHeight;
    		_parent = parent;
    		_player = player;		
			_loader = _player.createLoader();
    		_container = new Sprite();

				
    		loadNextImage();
    	}
    	
    	private function loadNextImage():void {

			var imageUrl:String = _coverFlowData[_currentIndex].customProperties.thumbnail;
			
			log.error("Loading image " + imageUrl);
			
			_loader.load(imageUrl, onImageLoadComplete);
		}
		
		protected function onImageLoadComplete(loader:ResourceLoader):void
		{


			var image:DisplayObject = loader.getContent() as DisplayObject;

			image.width = _imageWidth;
		  	image.height = _imageHeight;
		  	image.x = calculateXPos(_currentIndex, 100);
			image.y = 0;
			image.name = String(_currentIndex);
			image.addEventListener(MouseEvent.MOUSE_UP, seek);
					
			_images.push(image);

			_container.addChild(image);
			
			_currentIndex++

				
			if (_currentIndex < _coverFlowData.length) {
				
				
				loadNextImage();
			} else {
				
		
				_parent.addChild(_container);
				_container.x = 0;
				_container.y = 0;
				shiftToItem(3);
			}
		}
		
		private function calculateXPos(thumbIndex:Number, thumbWidth:Number):Number {
			var pos:Number = thumbIndex * thumbWidth;
   			pos += (thumbIndex + 1) * 5;
  
   			pos += Math.floor(thumbIndex/2) * 5;
   			return pos;
   		}
   
		public function showError(message:String):void
		{
			//log.error(message);
		}
		
		public function handleError(error:PlayerError, info:Object = null, throwError:Boolean = true):void
		{
			log.error(error.message);
		}
		
		public function seek(event:MouseEvent):void {
			var image:Sprite = event.target as Sprite;
			shiftToItem(Number(image.name));
		}
		
		public function shiftToItem(newImageIndex:int):void {


			log.error(newImageIndex.toString());
			if (_currentImageIndex == newImageIndex) 
				return;

			for (var i:Number=0; i < _images.length; i++) {
				
				
				if (i == newImageIndex) {
					//_player.animationEngine.animate(_images[i],{x: 0});
					
	
				// all the ones to the left
				
				} else if (i < newImageIndex) {
					log.error((newImageIndex - i+1).toString());
					//_player.animationEngine.animate(_images[i],{x: (newImageIndex - i+1)});					


				// all the ones to the right
				} else  {
					log.error((i-newImageIndex+1).toString());
					//_player.animationEngine.animate(_images[i],{x: (i-newImageIndex+1)});	
				
				}
			}
			
			_currentImageIndex = newImageIndex;		
			

		}
    }
}