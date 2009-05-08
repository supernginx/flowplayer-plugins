/**************************************

title: CoverFlow knockoff

author: John Dyer (http://johndyer.name)

license: MIT

updated: 12/12/2007

*************************************/
package org.flowplayer.related 
{	
    import caurina.transitions.Tweener;
    
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.geom.*;
    import flash.net.*;
    import flash.system.LoaderContext;
    import flash.text.*;
    import flash.ui.Keyboard;
    import flash.utils.*;
    
    import org.flowplayer.util.Log;
    import org.papervision3d.cameras.Camera3D;
    import org.papervision3d.core.*;
    import org.papervision3d.core.proto.*;
    import org.papervision3d.events.*;
    import org.papervision3d.materials.*;
    import org.papervision3d.objects.*;
    import org.papervision3d.objects.primitives.*;
    import org.papervision3d.scenes.Scene3D;


    public class CoverFlow2 extends EventDispatcher
    {		
		private var log:Log = new Log(this);
		private var showReflections:Boolean = true;	
		private var planes:Array = [];
		private var reflectedPlanes:Array = [];		
		private var tweens:Array = [];
		private var reflectedTweens:Array = [];		
		private var currentPlaneIndex:Number = 0;

		private var planeAngle:Number = 65;
		private var planeSeparation:Number = 65;
		private var planeOffset:Number = 60;
		private var selectPlaneZ:Number = -180;		
		private var tweenTime:Number = 0.8;
		private var planeWidth:Number = 265;
		private var planeHeight:Number = 200;	
		private var transition:String = "easeOutExpo"; //"easeOutSine";
		private var stage:Sprite;		
		private var camera:Camera3D;
		private var scene:Scene3D;				
		private var coverFlowData:Array;				
		private var textTitle:TextField = null;
		private var currentIndex:Number = 0;

		public var needsRender:Boolean = true;

		public function CoverFlow(stage:Sprite, camera:Camera3D, scene:Scene3D, coverFlowData:Array=null, showReflections:Boolean=true, planeWidth:Number=265, planeHeight:Number=200):void
        {						
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, mouseWheelHandler);				

			this.stage = stage;
			this.scene = scene;
			this.camera = camera;
			this.coverFlowData = coverFlowData;
			this.showReflections = showReflections;
			this.planeWidth = planeWidth;
			this.planeHeight = planeHeight;			
/*
			textTitle = new TextField();
			textTitle.autoSize = TextFieldAutoSize.CENTER;
			
			var textStyle:TextFormat = new TextFormat("Arial", 12, 0xffffff);
			textStyle.align = "center";
			textTitle.defaultTextFormat = textStyle;
			stage.addChild(textTitle);
			textTitle.y = 8; 
			textTitle.x = 700/2;*/

			if (coverFlowData != null)
				loadData();			
        }


		


		public function loadData(coverFlowData:Array=null):void {
			if (coverFlowData != null)
				this.coverFlowData = coverFlowData;
			currentIndex = 0;
			loadNextPlane();			

		}

		private function loadNextPlane():void {
			//textTitle.text = "Loading images ... " + (currentIndex+1) + " of " + coverFlowData.length;
			var loaderContext:LoaderContext = new LoaderContext ();
			loaderContext.checkPolicyFile = true;

			var imageLoader:Loader = new Loader();
			log.error("Loading thumbnail " + coverFlowData[currentIndex].customProperties.thumbnail);
			imageLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
			imageLoader.load( new URLRequest( coverFlowData[currentIndex].customProperties.thumbnail ), loaderContext );
			
			//var imageUrl:String = coverFlowData[currentIndex].thumbnail;
			//var loader:ResourceLoaderImpl = new ResourceLoaderImpl(null, this);
			//loader.load(imageUrl, onImageLoadComplete);
		}

		private function imageLoaded (e:Event):void {
			var plane:Plane = null;
			var loadedBmp : Bitmap = e.target.content as Bitmap;
			var bmp : BitmapData = loadedBmp.bitmapData;				
			var newWidth:Number = planeWidth;
			var newHeight:Number = planeHeight;			

			if (bmp.width > bmp.height) {
				newWidth = planeWidth;
				newHeight = bmp.height/bmp.width *planeWidth;
			} else {
				newWidth = bmp.width/bmp.height *  planeHeight;
				newHeight = planeHeight;				
			}
			
			newWidth = 75;
			newHeight = 75;
			
			var planeMaterial:BitmapMaterial = null;
			showReflections = false;
			if (showReflections) {
				var bmpWithReflection:BitmapData = new BitmapData(bmp.width, bmp.height*2, false, 0);
				// draw a copy of the image
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

				planeMaterial = new BitmapMaterial(bmpWithReflection);
				planeMaterial.smooth = false;
				planeMaterial.interactive = true;

				plane = new Plane( planeMaterial, newWidth, newHeight*2, 4, 4);
				plane.y = -planeHeight/2;
			} else {
				planeMaterial = new BitmapMaterial(bmp);
				planeMaterial.smooth= true;
				plane = new Plane( planeMaterial, newWidth, newHeight, 4, 4);				
			}
			
			var sprite:Sprite = new Sprite();
			sprite.width = newWidth;
			sprite.height = newHeight;
			sprite.addChild(loadedBmp);
			
			stage.addChild(sprite);
			// stack the images
			plane.z = (currentIndex+1 < coverFlowData.length/2) ? 
				(coverFlowData.length/2-currentIndex)*10 : 
				-(currentIndex - coverFlowData.length/2) * 10;
				
			log.error(currentIndex + ": " + plane.z);
			// delete the loaded iamge
			bmp.dispose();						
			plane.extra = {planeIndex : currentIndex, height: newHeight};
			scene.addChild(plane);
			planes.push(plane);
			plane.addEventListener(InteractiveScene3DEvent.OBJECT_CLICK, planeClicked);								

			if (currentIndex < coverFlowData.length-1) {
				currentIndex++
				loadNextPlane();
			} else {
				camera.lookAt( new DisplayObject3D() );
				shiftToItem(1);
			}
		}

		private function goToLink():void {
			var request:URLRequest = new URLRequest( coverFlowData[currentPlaneIndex].clickUrl );
			navigateToURL(request, "_blank");
		}

		private function planeClicked(ev:InteractiveScene3DEvent):void {
			var index:Number = ev.displayObject3D.extra.planeIndex;
			// don't click on the reflection
			if (!showReflections || ev.y <= ev.displayObject3D.extra.height ) {		
				if (index == currentPlaneIndex) {			
					goToLink();				
				} else {
					shiftToItem(index);		
				}
			}
		}
		
		private function keyDownHandler(ev:KeyboardEvent):void {
			switch (ev.keyCode) {
				case Keyboard.LEFT:
					moveLeft();
					break;
				case Keyboard.RIGHT:
					moveRight();
					break;
				case Keyboard.UP:
				case Keyboard.PAGE_UP:
					shiftToItem(0);
					break;					
				case Keyboard.DOWN:					
				case Keyboard.PAGE_DOWN:
					shiftToItem(planes.length-1);
					break;						
				case Keyboard.ENTER:
					goToLink();
					break;
			}
		}

		private function mouseWheelHandler(event:MouseEvent):void
		{		
			if (event.delta < 0) 
				moveRight();
			else 
				moveLeft();
		}		
		
		public function moveLeft():void {
			if (currentPlaneIndex > 0) {
				shiftToItem(currentPlaneIndex-1);
			}			
		}

		public function moveRight():void {
			if (currentPlaneIndex < planes.length -1) {
				shiftToItem(currentPlaneIndex+1);				
			}			
		}
		
		private function onCompleteTransition():void
		{
			needsRender = false;
		}

		public function shiftToItem(newCenterPlaneIndex:int):void {

			needsRender = true;

			if (currentPlaneIndex == newCenterPlaneIndex) 
				return;

			for (var i:Number=0; i<planes.length; i++) {
				
				var plane:Plane = planes[i] as Plane;				
				// smoothing only the main one or the one immediately left or right
				if (i >= newCenterPlaneIndex-1 && i <= newCenterPlaneIndex+1) {
					plane.material.smooth = true;
				} else {
					plane.material.smooth = false;					
				}
				
				if (i == newCenterPlaneIndex) {
					tweens[i] = Tweener.addTween(plane, 
									 {x: 0,
									 z: selectPlaneZ,
									 rotationY: 0,
									 time:tweenTime, 
									 transition:transition,
									 onComplete: onCompleteTransition});		

				// all the ones to the left
				
				} else if (i < newCenterPlaneIndex) {
											
					tweens[i] = Tweener.addTween(plane, 
									 {x: (newCenterPlaneIndex - i+1) * -planeSeparation - planeOffset, 
									 z: 0,
									 rotationY: -planeAngle,
									 time:tweenTime, 										 
									 transition:transition});

				// all the ones to the right
				} else  {
					tweens[i] = Tweener.addTween(plane, 
									 {x: ((i-newCenterPlaneIndex+1) * planeSeparation) + planeOffset, 
									 z: 0,
									 rotationY: planeAngle,
									 time:tweenTime, 
									 transition:transition});	
				}
			}
			
			currentPlaneIndex = newCenterPlaneIndex;		
			textTitle.text = coverFlowData[currentPlaneIndex].title;
			dispatchEvent(new CoverFlowEvent(CoverFlowEvent.ITEM_FOCUS, newCenterPlaneIndex));

		}
    }
}