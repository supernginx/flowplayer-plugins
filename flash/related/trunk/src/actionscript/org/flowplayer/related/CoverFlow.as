package org.flowplayer.related {
	
	import com.awen.Callback;
	import com.hydrotik.go.HydroTween;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.flowplayer.util.Log;
	import org.flowplayer.related.assets.NextBtn;
	import org.flowplayer.related.assets.PreloadAnimation;
	import org.flowplayer.related.assets.PrevBtn;
	
	import org.papervision3d.core.effects.view.ReflectionView;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
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
    	
    	//[Embed(source="../../../../flash/preloader.swf", symbol="org.flowplayer.view.BufferAnimation")]
        //private var PreloadAnimation:Class;
		private var preloadAnimation:Sprite;
		
		
		private static const Z_FOCUS:Number = -100;
		private var pageSpacing:Number = 50;
		private var imagePadding:Number = 100;
		private var scrollX:Number;
		private var containerXInterval:int;
		private var speed:Number = 6;
		private var totalPages:Number;
		private var pageWidth:Number;
		private var currentPage:Number = 1;
		private var intervalSpeed:Number = 40;
		
		private var prevBtn:Sprite;
		private var nextBtn:Sprite;
		private var _maxItems:int;
		private var _margin:int;

	
		
    	public function CoverFlow(config:Object):void
    	{
    		//super(width,height,false,true,"Target");
    		
    		//log.debug("width: " + width);
    		_imageWidth = config.imageWidth;
    		_imageHeight = config.imageHeight;
    		_maxItems = config.items;
    		_margin = config.horizontalSpacing;
    		
			setReflectionColor(1, 1, 1);
    		_config = config;
			viewportReflection.alpha = .8;
			viewport.interactive = true;
			camera.z = -800;
			if (_config.showReflection) surfaceHeight = -_imageHeight; 
			//renderer.clipping = new FrustumClipping(FrustumClipping.BOTTOM)
			viewport.buttonMode = true;
			//viewport.viewportWidth = width;
 			//viewport.viewportHeight = height;
			

			
			
			
			addEventListener(Event.ADDED_TO_STAGE, setGradient);

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
		
			prevBtn = new PrevBtn();
  			prevBtn.x = 5;
  			prevBtn.y = 140;
  			prevBtn.buttonMode = true;
  			prevBtn.visible = true;
  			prevBtn.addEventListener(MouseEvent.CLICK, prevPage);
  			addChild(prevBtn);
  			
  			nextBtn = new NextBtn();
		
  			nextBtn.x = stage.width - (nextBtn.width + 5);
  			
  			nextBtn.y = 0;
  			
  			nextBtn.y = 140;
  			nextBtn.buttonMode = true;
  			nextBtn.visible = true;
  			nextBtn.addEventListener(MouseEvent.CLICK, nextPage);
  			addChild(nextBtn);
  			
  			updateNavigation();
			
    	}
    	
    	public function clear():void
    	{
    		_currentIndex = 0;
    		_coverFlowData = null;

			scene.removeChild(_container);
    	}
		
		private function loop(event:Event):void
        {			
			//var mouseX:Number = viewport.containerSprite.mouseX + width;
			
			var mouseX:Number = stage.mouseX;
			var maxScroll:Number = stage.width - this.pageWidth;
			var percent:Number = mouseX/maxScroll;
			var scroll:Number = (percent*(this.pageWidth));
			
			//scroll = scroll < maxScroll ? maxScroll + (_imageWidth - _margin) : scroll + (_imageWidth + _margin);
			//log.debug("pageWidth: " + this.stage.width);
			/*
			 log.debug("pageWidth: " + this.pageWidth);
			  log.debug("max scroll: " + maxScroll);
             log.debug("percent: " + percent);
             log.debug("scroll" + scroll);*/
          
			 
			//log.debug(mouseX.toString());
            //mouseX = Math.max(0, mouseX);
            //mouseX = Math.min(this.width, mouseX);
   
            //var widthX:Number = stage.width - this.width + imagePadding;
            //var spacing:Number = -(stage.width - pageSpacing) * this.currentPage + imagePadding / 2;
            //scrollTo(_loc4 - mouseX / this.width * widthX);
          	//this.scrollX = (spacing - (mouseX / this.width) * widthX) + 7 + _imageWidth;
          	//this.scrollX = scroll;
          	
          	//this.scrollX = -stage.width;
          	this.scrollX = scroll;
          	
			//HydroTween.go(_container, {x: -viewport.containerSprite.mouseX} , 5);
			this.singleRender();
			
        }
        
        private function updateXPosition():void
    	{
    		//_container.x = -stage.width;
    		_container.x = _container.x - (_container.x - this.scrollX) / 6;
    		//HydroTween.go(_container, {x: _container.x - (_container.x - this.scrollX)} , 3);
    	
    		singleRender();
    	}
    	
    	private function nextPage(event:MouseEvent):void
    	{
    		setPage(this.currentPage + 1);	
    	}
    	
    	private function prevPage(event:MouseEvent):void
    	{
    		setPage(this.currentPage - 1);	
    	}
    	
    	private function setPage(page:Number):void
    	{
    		this.currentPage = page;
    		stopScrolling();
    		var pageX:Number = -this.currentPage * (this.pageWidth + this.pageSpacing);

    		HydroTween.go(_container, {x: pageX} , 5,0,null,null,startScrolling);
    		updateNavigation();
    	}
    	
    	private function stopScrolling():void
    	{
    		clearInterval(containerXInterval);
    	}
    	
    	private function startScrolling():void
    	{
    		containerXInterval = setInterval(updateXPosition, intervalSpeed);
    	}
    	
        
    	private function updateNavigation():void
    	{
 
    		if (currentPage == totalPages)
    		{
    			nextBtn.visible = false;
    		} else {
    			nextBtn.visible = true;
    		}
    		
    		if (currentPage == 1)
    		{
    			prevBtn.visible = false;
    		} else {
    			prevBtn.visible = true;
    		}
    		
    	}
		
		
		public function set data(data:Array):void
		{
			_coverFlowData = data;
			
			loadImages();
		}
		
		private function loadImages():void
		{
			this.pageWidth = (_coverFlowData.length > _maxItems) 
  							? ((_imageWidth + _margin) * _maxItems)
  							: ((_imageWidth + _margin) * _coverFlowData.length);
  							
    		// log.debug(this.pageWidth.toString());
    		 
    		this.totalPages = Math.ceil(_coverFlowData.length / _maxItems);
    		
    	
			updateNavigation();
				
			for (var i:int = 0; i < _coverFlowData.length; i++)
        	{
        		_currentIndex = i;
        		
        		var preloadAnimation:Sprite = new PreloadAnimation() as Sprite;
 				preloadAnimation.width = 20;
 				preloadAnimation.height = 20;
 				
 				var mmaterial:MovieMaterial = new MovieMaterial(preloadAnimation,true,true);
				mmaterial.allowAutoResize = false;
				mmaterial.interactive = true;
				mmaterial.interactive = true ;
				mmaterial.oneSide = false;
				mmaterial.smooth = true;
				mmaterial.rect = new Rectangle( 0, 0, 20,20);
				
        		
        		//var material:BitmapFileMaterial = new BitmapFileMaterial(_coverFlowData[_currentIndex]);
        		//material.smooth= true;
				//material.doubleSided = true;
				//material.interactive = true;
	
				var plane:Plane = new Plane( mmaterial, _imageWidth, _imageHeight, 1, 1);
				plane.scale = 0.5;
				_container.addChild(plane);
				
				//var xDist:Number = stage.width-(_currentIndex * (_imageWidth +  _config.horizontalSpacing));
				var xDist:Number = (_currentIndex * (_imageWidth +  _config.horizontalSpacing));
        		
        		HydroTween.go(plane, {x: xDist} , 1);
			//	plane.y = _config.reflectionSpacing;
				plane.z = 0;
				plane.extra = {planeIndex : _currentIndex, height:  _imageHeight};
				
				
				
				planes.push(plane);
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onOver);	
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onOut);	
				plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onClick);						
				//plane.addEventListener(InteractiveScene3DEvent.OBJECT_MOVE, onMove);
				
				var loader:Loader = new Loader();
 				
 				var loaderContext:LoaderContext = new LoaderContext();
				loaderContext.checkPolicyFile = false;
			
 				loader.load(new URLRequest(_coverFlowData[_currentIndex]));
 				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,Callback.create(onLoaderComplete,plane));

        	}
        	
        	scene.addChild(_container);
        	
        	//setInterval(scrollTo, intervalSpeed);
        	addEventListener(Event.ENTER_FRAME, loop);
        	startScrolling();
        	
        	startRendering();
		}
		
		
		private function onLoaderComplete(event:Event, planeObj:Plane):void
        {
        	
        	var image:Bitmap = event.target.content as Bitmap;
			image.width = _imageWidth;
			image.height = _imageHeight;
			  	
			var bmp:BitmapMaterial = new BitmapMaterial(image.bitmapData);
			bmp.doubleSided = true;
			bmp.smooth = true;
			bmp.interactive = true;
	

			planeObj.material = bmp;
			planeObj.scale = 1;
			
			event.currentTarget.loader.unload();
        }
		/*
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
		}*/
		
		
		private function onOver(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			viewport.containerSprite.buttonMode = true;
			//HydroTween.go(plane,  {z:Z_FOCUS, y: plane.y - 10, rotationY:0}, 0.5);
			HydroTween.go(plane,  {scaleX:1.1, scaleY:1.1, y:0}, 4.000000E-001);
			//TweenMax.to(plane, TIME, {z:Z_FOCUS, rotationY:0});
			
			_config.mouseOverListener(plane.extra.planeIndex);
		}
		
		private function onOut(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			//TweenMax.to(plane, TIME, {z:0, rotationY:0});
			//HydroTween.go(plane,  {z:0, y: 0, rotationY:0}, 0.2);
			HydroTween.go(plane,  {scaleX:1, scaleY:1,y:0}, 4.000000E-001);
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