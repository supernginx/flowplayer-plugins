package org.flowplayer.related {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	
	
	import org.flowplayer.util.Log;

	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.BitmapMaterial;

	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.core.effects.view.ReflectionView;
	import 	org.papervision3d.core.clipping.FrustumClipping;

	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.Shape;
	 import flash.display.Bitmap;
	 import flash.display.BitmapData;
	
	public class CoverFlow extends ReflectionView
    {
    	private var _coverFlowData:Array;
    	private var _imageWidth:Number;
    	private var _imageHeight:Number;
    	private var _currentIndex:Number = 0;
    	private var _currentImageIndex:Number = 0;
    	private var log:Log = new Log(this);
		private var planes:Array = [];
		private var _config:Object;    	
    	private var _container:DisplayObject3D = new DisplayObject3D();

		
		private static const SPACING:Number = 100;
		private static const NUMBER_OF_PLANES:int = 10;
		private static const TIME:Number = .5;
		private static const Z_FOCUS:Number = -100;
		private static const ROTATION_Y:Number = 0;

		
    	public function CoverFlow(config:Object):void
    	{
    		_imageWidth = config.imageWidth;
    		_imageHeight = config.imageHeight;
			setReflectionColor(1, 1, 1);
    		_config = config;
			viewportReflection.alpha = .8;
			viewport.interactive = true;
			camera.z = -800;
			if (_config.showReflection) surfaceHeight = -_imageHeight; 
			//renderer.clipping = new FrustumClipping(FrustumClipping.BOTTOM)
			viewport.buttonMode = true;
			
	
			
			addEventListener(Event.ENTER_FRAME, loop);
			addEventListener(Event.ADDED_TO_STAGE, setGradient);
    		//loadNextImage();
    	}
    	

    	
    	private function setGradient(e:Event):void
    	{
    		
    		
			// Fade				
			var holder:Shape = new Shape();
			var gradientMatrix:Matrix = new Matrix();
			
			gradientMatrix.createGradientBox(stage.width, stage.height, Math.PI/2 , 0 , 0);
			
			holder.graphics.beginGradientFill( GradientType.LINEAR, [0x000000, 0x000000], [0, 1], [0x00, 0x7E], gradientMatrix);
			holder.graphics.drawRect(0, 0, stage.width, stage.height);
			holder.graphics.endFill();
			holder.cacheAsBitmap = true;
			
			viewportReflection.cacheAsBitmap = true;
			viewportReflection.addChild(holder);
			holder.x = 0;
			holder.y = Math.floor(_imageHeight * _config.maskRatio);
			
			

			viewportReflection.mask = holder;
			
    	}
    	
    	public function clear():void
    	{
    		_currentIndex = 0;

    		
    	//	while(scene.numChildren > 0) scene.removeChildAt(scene.numChildren-1);
    //		while(_container.numChildren > 0) _container.removeChildAt(_container.numChildren-1);
			
			scene.removeChild(_container);
    	}
		
		private function loop(event:Event):void
        {			
			TweenMax.to(_container, TIME, {x:-viewport.containerSprite.mouseX, ease: 'Expo.easeIn'});
			this.singleRender();
			
        }
		
		/*
    	private function loadNextImage():void {

			var imageUrl:String = _coverFlowData[_currentIndex].customProperties.thumbnail;
			
			log.error("Loading image " + imageUrl);
			
			_loader.load(imageUrl, onImageLoadComplete);
		}
		*/
		
		public function addImage(image:DisplayObject):void
		{
			image.width = _imageWidth;
			image.height = _imageHeight;
	
			var planeMaterial:MovieMaterial = null;
			var plane:Plane = null;
				
			planeMaterial = new MovieMaterial(image);
			planeMaterial.smooth= true;
			planeMaterial.doubleSided = true;
			planeMaterial.interactive = true;
			
			plane = new Plane( planeMaterial, _imageWidth, _imageHeight, 4, 4);
			
			_container.addChild(plane);
			
			plane.x = _currentIndex * (_imageWidth + _config.horizontalSpacing);
			plane.y = _config.relfectionSpacing;
			plane.rotationY = 0;
			plane.z = 0;
			plane.extra = {planeIndex : _currentIndex, height:  _imageHeight};

			scene.addChild(_container);
		
			planes.push(plane);
			plane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onOver);	
			plane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onOut);
			plane.addEventListener(InteractiveScene3DEvent.OBJECT_RELEASE, onClick);
			
			_currentIndex++
		}
		
		
		private function onOver(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			viewport.containerSprite.buttonMode = true;
			TweenMax.to(plane, TIME, {z:Z_FOCUS, rotationY:0});
			
			_config.mouseOverListener(plane.extra.planeIndex);
		}
		
		private function onOut(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			TweenMax.to(plane, TIME, {z:0, rotationY:0});
			viewport.containerSprite.buttonMode = false;
			_config.mouseOutListener();
		}
		
		private function onClick(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			
			_config.mouseClickListener(plane.extra.planeIndex);

		}
		
		//private function onMove(event:MouseEvent):void
		private function onMove(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			//log.error(plane.extra.planeIndex.toString());
			//flow(plane);		
			//shiftToItem(plane);	
		}
    }
}