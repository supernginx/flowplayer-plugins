package org.flowplayer.related {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	
	import org.flowplayer.controller.ResourceLoader;
	import org.flowplayer.model.PlayerError;
	import org.flowplayer.util.Log;
	import org.flowplayer.view.ErrorHandler;
	import org.flowplayer.view.Flowplayer;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.BitmapMaterial;

	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.core.effects.view.ReflectionView;

	import flash.geom.Matrix;
	import flash.filters.BlurFilter;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	 import flash.display.Bitmap;
	 import flash.display.BitmapData;
	
	public class CoverFlow extends ReflectionView implements ErrorHandler
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
    	private var planeSeparation:Number = 65;

		private var planeOffset:Number = 60;
		
		private static const SPACING:Number = 100;
		private static const NUMBER_OF_PLANES:int = 10;
		private static const TIME:Number = .5;
		private static const Z_FOCUS:Number = -100;
		private static const ROTATION_Y:Number = 0;

		private var _view:BasicView;
		private var planes:Array = [];
		
		private var carousel:DisplayObject3D = new DisplayObject3D();
		
	
    	public function CoverFlow(parent:Sprite, coverFlowData:Array, imageWidth:Number, imageHeight:Number, player:Flowplayer):void
    	{
    		_coverFlowData = coverFlowData;
    		_imageWidth = imageWidth;
    		_imageHeight = imageHeight;
    		_parent = parent;
    		_player = player;		
			_loader = _player.createLoader();
			
			viewportReflection.filters = [new BlurFilter(3,3,1)];
			setReflectionColor(.5, .5, .5);
			viewport.interactive = true;
			surfaceHeight = -50; 
			camera.z = 800;
			
			viewport.buttonMode = true;
			
			//viewport.interactiveSceneManager.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, onMove);
			//viewport.interactive = true;
			
			
			addEventListener(Event.ENTER_FRAME, loop);
			
				
    		loadNextImage();
    	}
    	
		
		private function loop(event:Event):void
        {			
			//carousel.x = viewport.containerSprite.mouseX;
			TweenMax.to(carousel, TIME, {x:viewport.containerSprite.mouseX});
			this.singleRender();
			
        }
		
    	private function loadNextImage():void {

			var imageUrl:String = _coverFlowData[_currentIndex].customProperties.thumbnail;
			
			log.error("Loading image " + imageUrl);
			
			_loader.load(imageUrl, onImageLoadComplete);
		}
		
		protected function onImageLoadComplete(loader:ResourceLoader):void
		{
			var showReflections:Boolean = true;
			var plane:Plane = null;
			/*if (showReflections) {
				var image2:Bitmap = loader.getContent() as Bitmap;
				var bmp:BitmapData = image2.bitmapData;	
				var bmpWithReflection:BitmapData = new BitmapData(bmp.width, bmp.height*2, false, 0);
				bmpWithReflection.draw(bmp);
				// draw the reflection, flipped
				var alpha:Number = 0.3;
            	var flipMatrix:Matrix = new Matrix(1, 0, 0, -1, 0, bmp.height*2 + 4);
           		bmpWithReflection.draw( bmp, flipMatrix, new ColorTransform(alpha, alpha, alpha, 1, 0, 0, 0, 0) );    
				
				// Fade				
				var holder:Shape = new Shape();
				var gradientMatrix:Matrix = new Matrix();
				gradientMatrix.createGradientBox( bmp.width, bmp.height, Math.PI/2 );

				holder.graphics.beginGradientFill( GradientType.LINEAR, [ 0, 0 ], [ 0, 100 ], [ 0, 0xFF ], gradientMatrix)
				holder.graphics.drawRect(0, 0, bmp.width, bmp.height);
				holder.graphics.endFill();

				var m:Matrix  = new Matrix();
				m.translate(0, bmp.height);
				bmpWithReflection.draw( holder, m );
				
				var bmpMaterial:BitmapMaterial = null;
		
				
				bmpMaterial = new BitmapMaterial(bmpWithReflection);
				bmpMaterial.smooth = false;
				bmpMaterial.interactive = true;
				
				plane = new Plane( bmpMaterial, _imageWidth, _imageHeight*2, 4, 4);
				plane.y = -_imageHeight/2;
				plane.extra = {planeIndex : _currentIndex, height:  _imageHeight};
	
			} else {*/
				var image:DisplayObject = loader.getContent() as DisplayObject;
				
				image.width = _imageWidth;
			  	image.height = _imageHeight;
	
				var planeMaterial:MovieMaterial = null;
				
				
				planeMaterial = new MovieMaterial(image);
				planeMaterial.smooth= true;
				planeMaterial.doubleSided = true;
				planeMaterial.interactive = true;
				plane = new Plane( planeMaterial, _imageWidth, _imageHeight, 4, 4);
				plane.x = _currentIndex * _imageWidth + 20;
				plane.rotationY = 0;
				plane.z = 0;
			
				//plane.y = -_imageHeight*2;	
				plane.extra = {planeIndex : _currentIndex, height:  _imageHeight};
				
				carousel.addChild(plane);
			//}
			
			//scene.addChild(plane);
			scene.addChild(carousel);
			/*plane.z = (_currentIndex+1 < _coverFlowData.length/2) ? 
				(_coverFlowData.length/2-_currentIndex)*10 : 
				-(_currentIndex - _coverFlowData.length/2) * 10;*/
				
			planes.push(plane);
			//plane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, onClick);								
			//plane.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, onMove);
			
			
			
			
			_currentIndex++	
			if (_currentIndex < _coverFlowData.length) {

				loadNextImage();
			} else {
			//	shiftToItem(plane);
				startRendering();
			}
		}
		
		private function calculateXPos(thumbIndex:Number, thumbWidth:Number):Number {
			var pos:Number = thumbIndex * thumbWidth;
   			pos += (thumbIndex + 1);
  
   			pos += Math.floor(thumbIndex/2);
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
		
		private function onClick(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			//trace(_coverFlowData[plane.extra.planeIndex].thumbnail);
			//flow(plane);		
			//shiftToItem(plane);	
		}
		
		//private function onMove(event:MouseEvent):void
		private function onMove(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			log.error(plane.extra.planeIndex.toString());
			//flow(plane);		
			//shiftToItem(plane);	
		}
		
		
		public function shiftToItem(plane:Plane):void
		{
			var xPosition:Number = 0;
			var xLPosition:Number = 0;
			var xRPosition:Number = 0;
			
			var newCenterPlaneIndex:int = plane.extra.planeIndex;
			
			//if (currentPlaneIndex == newCenterPlaneIndex) 
			//	return;
			for (var i:Number=0; i<planes.length; i++) {
				var plane:Plane = planes[i] as Plane;				
				
					// smoothing only the main one or the one immediately left or right
				if (i >= newCenterPlaneIndex-1 && i <= newCenterPlaneIndex+1) {
						plane.material.smooth = true;
				} else {
						plane.material.smooth = false;					
				}
				
				if (i == newCenterPlaneIndex) {
					TweenMax.to(plane, TIME, {x:xPosition, z:Z_FOCUS, rotationY:0});
				// all the ones to the left
				} else if (i < newCenterPlaneIndex) {
					xLPosition -= SPACING;
					//TweenMax.to(plane, TIME, {x:xLPosition, z:0, rotationY:ROTATION_Y});
					TweenMax.to(plane, TIME, {x:(newCenterPlaneIndex - i+1) * -planeSeparation - planeOffset, z:0, rotationY:ROTATION_Y});
				} else {
					xRPosition += SPACING;
					//TweenMax.to(plane, TIME, {x:xRPosition, z:0, rotationY:ROTATION_Y});
					TweenMax.to(plane, TIME, {x:((i-newCenterPlaneIndex+1) * planeSeparation) + planeOffset, z:0, rotationY:ROTATION_Y});
				}
			}
			
			
		}
		
		/*
		public function shiftToItem(newImageIndex:int):void {


			log.error(newImageIndex.toString());
			if (_currentImageIndex == newImageIndex) 
				return;

			for (var i:Number=0; i < _images.length; i++) {
				
				
				if (i == newImageIndex) {
					//_player.animationEngine.animate(_images[i],{x: 0});
					_player.animationEngine.animate(_container,{x: 0});
	
				// all the ones to the left
				
				} else if (i < newImageIndex) {
					//log.error((newImageIndex * _imageWidth).toString());
					//log.error((i * _imageWidth).toString());
					//log.error((newImageIndex - (i-1 * _imageWidth)).toString());
					//_player.animationEngine.animate(_images[i],{x: (newImageIndex - (i+1 * _imageWidth))});					
					_player.animationEngine.animate(_container,{x: (newImageIndex - (i+1 * _imageWidth))});

				// all the ones to the right
				} else  {
					//log.error((i-newImageIndex+1).toString());
					//_player.animationEngine.animate(_images[i],{x: (i-newImageIndex+1)});	
					_player.animationEngine.animate(_container,{x: (i-newImageIndex+1)});	
				
				}
			}
			
			_currentImageIndex = newImageIndex;		
			

		}*/
    }
}