package org.flowplayer.related {
	
	import com.awen.Callback;
	import com.hydrotik.go.HydroTween;
	
	import flash.display.Bitmap;
    import flash.display.BitmapData;
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
	import org.papervision3d.core.effects.view.ReflectionView;
	import org.papervision3d.events.InteractiveScene3DEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	
	import org.flowplayer.related.assets.NextBtn;
	import org.flowplayer.related.assets.PreloadAnimation;
	import org.flowplayer.related.assets.PrevBtn;

    public class CoverFlow extends ReflectionView
    {
        private var _coverFlowData:Array;
        private var _imageWidth:Number;
        private var _imageHeight:Number;
        private var _currentIndex:Number = 0;
        private var _currentImageIndex:Number = 0;
        private var log:Log = new Log(this);
        private var _config:Object;
        private var _pageContainers:Array;
        private var preloadAnimation:Sprite;
//        private var imagePadding:Number = 100;
        private var scrollX:Number;
        private var containerXInterval:int;
        private var speed:Number = 6;
        private var intervalSpeed:Number = 40;
        private var _pageItems:Array = [];
        private var prevBtn:Sprite;
        private var nextBtn:Sprite;
        private var _maxItems:int;
        private var _margin:Number;
        private var pager:Pager;
        private var _reflectionCreated:Boolean;

		
    	public function CoverFlow(config:Object):void
    	{
    		_imageWidth = config.imageWidth;
    		_maxItems = config.items;
    		_margin = config.horizontalSpacing;
    		
			setReflectionColor(1, 1, 1);
    		_config = config;
//			viewportReflection.alpha = .8;
			viewport.interactive = true;
            camera.z = -800;
//            camera.z = 0;
			//renderer.clipping = new FrustumClipping(FrustumClipping.BOTTOM)
			viewport.buttonMode = true;

			addEventListener(Event.ADDED_TO_STAGE, function(event:Event):void { createButtons() });
    	}

        override public function set height(value:Number):void {
            _imageHeight = value / 2;
            // _imageHeight = value;
            if (_config.showReflection) {
                surfaceHeight = - _imageHeight;
            }
            log.debug("set height() value = " + _imageHeight);
//            setReflection();

//            if (_pageContainers) {
//                var children:Object = container.children;
//                for (var name:String in children) {
//                    var bmp:BitmapData = BitmapMaterial(Plane(container.getChildByName(name)).material).bitmap;
//                }
//            }
        }
    	
    	private function setReflection():void
    	{
            if (_reflectionCreated) return;
            _reflectionCreated = true;
            
			// Fade
			var holder:Shape = new Shape();
			var gradientMatrix:Matrix = new Matrix();
			
			gradientMatrix.createGradientBox(stage.width, _imageHeight, Math.PI/2 , 0 , 0);
			
			holder.graphics.beginGradientFill( GradientType.LINEAR, [0x000000, 0x000000], [0, 0.8], [0x00, 0x7E], gradientMatrix);
			holder.graphics.drawRect(0, 0, stage.width, _imageHeight);
			holder.graphics.endFill();
			holder.cacheAsBitmap = true;
			
			viewportReflection.cacheAsBitmap = true;
			//viewportReflection.addChild(holder);
			holder.x = 0;
//			holder.y = Math.floor(_imageHeight * _config.maskRatio);
            holder.y = _imageHeight;
			
			//viewportReflection.mask = holder;
    	}

        private function createButtons():void {
            prevBtn = new PrevBtn();
            prevBtn.x = 5;
            prevBtn.y = 140;
            prevBtn.buttonMode = true;
            prevBtn.visible = true;
            prevBtn.addEventListener(MouseEvent.CLICK, prevPage);
            addChild(prevBtn);

            nextBtn = new NextBtn();

            nextBtn.x = stage.stageWidth - (nextBtn.width + 5);
            nextBtn.y = 140;
            nextBtn.buttonMode = true;
            nextBtn.visible = true;
            nextBtn.addEventListener(MouseEvent.CLICK, nextPage);
            addChild(nextBtn);
        }

    	public function clear():void
    	{
    		_currentIndex = 0;
    		_coverFlowData = null;
            if (! _pageContainers) return;
            
			for (var i:int = 0; i < _pageContainers.length; i++) {
                scene.removeChild(_pageContainers[i]);
            }
    	}
    	
        public function get currentPageWidth():Number {
            return ((_imageWidth + _margin) * pager.getPageItemCount() - _margin);
        }

        private function getPageScroll(page:int):Number {
            return currentPageWidth/2;
        }
		
        private function loop(event:Event):void
        {			
            var currentPageScroll:Number = outsideLength > 0 ? ((this.mouseX-stage.stageWidth/2)/stage.stageWidth) * outsideLength : 10;
            this.scrollX = - getPageScroll(pager.currentPageID) - currentPageScroll;
            if (this.scrollX < - (currentPageWidth - width)) {
                this.scrollX = - (currentPageWidth - width);
            }
            if (this.scrollX > - width/2) {
                this.scrollX = - width/2;
            }

            this.singleRender();
        }

        public function get outsideLength():Number {
            if (currentPageWidth < width) return 0;
            return currentPageWidth - width;
        }
        
        private function updateXPosition():void
    	{
    		container.x = container.x - (container.x - this.scrollX) / 6;
    		singleRender();
    	}

        private function get container():DisplayObject3D {
            return _pageContainers[pager.currentPageID] as DisplayObject3D;
        }

        public function set containerX(value:Number):void {
//            stopScrolling();
            removeEventListener(Event.ENTER_FRAME, loop);

            this.scrollX = value;
            singleRender();
        }
    	
    	private function nextPage(event:MouseEvent):void
    	{
    		pager.currentPageID = pager.nextPageID;
    		setPage(pager.currentPageID);	
    	}
    	
    	private function prevPage(event:MouseEvent):void
    	{
    		pager.currentPageID = pager.previousPageID;
    		setPage(pager.currentPageID);	
    	}
    	
    	private function setPage(page:Number):void
    	{
            log.debug("setPage() " + page + ", currentPage " + pager.currentPageID);
    		stopScrolling();
			var pageX:Number = - getPageScroll(page);

            log.debug("removing container " + _pageContainers[pager.oldPage]["name"]);
            scene.removeChild(_pageContainers[pager.oldPage]);
            log.debug("adding container " + container.name);
            scene.addChild(container);

    		container.x = page > 0 ? pageX : - width;
            container.y = 0;
    		
    		startScrolling();
    	}
    	
    	private function pageChangeHandler():void
    	{
    		_config.pagingListener();
    	}
    	
    	private function stopScrolling():void
    	{
    		clearInterval(containerXInterval);
    	}
    	
    	private function startScrolling():void
    	{
    		containerXInterval = setInterval(updateXPosition, intervalSpeed);
    	}

		public function set data(data:Array):void
		{
			_coverFlowData = data;
			loadImages();
		}
		
		public function getResults():String
		{
			return pager.getResults();	
		}
		
		public function get totalPages():Number
		{
			return pager.totalPages;
		}
		
		public function get currentPage():Number
		{
			return pager.currentPageID;
		}
		
		public function get pageItems():Number
		{
			return pager.totalItems;
		}
		
		private function loadImages():void
		{
            _pageContainers = [];
        	pager = new Pager({itemData: _coverFlowData, perPage: _maxItems, pageChangeHandler: pageChangeHandler, nextBtn: nextBtn, prevBtn:prevBtn, pageInfoText: "{0}-{1} of {2}" });
        	pager.currentPageID = 0;

            var preloadAnimation:Sprite = new PreloadAnimation() as Sprite;
            preloadAnimation.width = 20;
            preloadAnimation.height = 20;

            var mmaterial:MovieMaterial = new MovieMaterial(preloadAnimation,true,true);
            mmaterial.allowAutoResize = false;
            mmaterial.interactive = true;
            //mmaterial.interactive = true;
            mmaterial.oneSide = false;
            mmaterial.smooth = true;
           // mmaterial.rect = new Rectangle( 0, 0, 20,20);

            var pageData:Array = pager.pageData;

            for (var pageNum:int = 0; pageNum < pageData.length; pageNum++)  {
                var xDist:Number = 0;
                var pageContainer:DisplayObject3D = new DisplayObject3D("page"+pageNum);
                _pageContainers.push(pageContainer);

                for (var i:Object in pager.getPageData(Number(pageNum)))
                {
                    xDist += i==0 ? 0 : (_imageWidth + _margin);

					//var plane:Plane = new Plane( mmaterial, 30, 30, 1, 1);
					var plane:Plane = new Plane( mmaterial, _imageWidth, _imageHeight, 1, 1);
//					plane.scale = 0.5;
					pageContainer.addChild(plane);
					
	        		HydroTween.go(plane, {x: xDist} , 1, 0, null, null, null,[_currentIndex]);
	        		
					plane.z = 0;
					plane.extra = {planeIndex : _currentIndex, height:  _imageHeight};

					var loader:Loader = new Loader();
	 				
	 				var loaderContext:LoaderContext = new LoaderContext();
					loaderContext.checkPolicyFile = false;
				
	 				loader.load(new URLRequest(pageData[pageNum][i]));
	 				//log.debug(_coverFlowData.toString());
	 				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,Callback.create(onLoaderComplete, { "plane": plane, "container": pageContainer, "x": xDist, "index": _currentIndex }));
					
					_currentIndex++;
	        	}
   			}

            setPage(pager.currentPageID);
        	
			_config.pagingListener();
			setReflection();
        	addEventListener(Event.ENTER_FRAME, loop);
    		startScrolling();
        	startRendering();
		}
		
		private function onLoaderComplete(event:Event, info:Object):void
        {
        	
        	var image:Bitmap = event.target.content as Bitmap;
         //   image.height = _imageHeight;
          //  image.scaleX = image.scaleY;
			image.width = _imageWidth;
			image.height = _imageHeight;
			  	
			var bmp:BitmapMaterial = new BitmapMaterial(image.bitmapData);
			bmp.doubleSided = true;
			bmp.smooth = true;
			bmp.interactive = true;


            //var container:DisplayObject3D = info["container"];
            //container.removeChild(info["plane"]);
            
            /*var plane:Plane = new Plane(bmp, image.width, _imageHeight);
            plane.z = 0;
            plane.extra = {planeIndex : info["index"], height: _imageHeight};
            plane.addEventListener(InteractiveScene3DEvent.OBJECT_OVER, onOver);
            plane.addEventListener(InteractiveScene3DEvent.OBJECT_OUT, onOut);
            plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, onClick);
            container.addChild(plane);*/
            
            var plane:Plane = info["plane"];
            plane.material = bmp;
            HydroTween.go(plane, {x: info["x"]} , 1, 0, null, null, null, [info["index"]]);
            
            

			event.currentTarget.loader.unload();
        }

		private function onOver(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
			viewport.containerSprite.buttonMode = true;
			HydroTween.go(plane,  {scaleX:1.2, scaleY:1.2, y:0}, 4.000000E-001);

			_config.mouseOverListener(plane.extra.planeIndex);
		}
		
		private function onOut(event:InteractiveScene3DEvent):void
		{
			var plane:Plane = Plane(event.target);
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
		}

        public function get mouseRatio():Number {
            return (this.mouseX-stage.stageWidth/2)/stage.stageWidth;
        }

        public function set cameraZ(value:int):void {
            camera.z = value;
        }
    }
}