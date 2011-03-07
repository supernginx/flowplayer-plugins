package org.flowplayer.playlist.scroller {

    
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
	import flash.geom.ColorTransform;

	import org.flowplayer.playlist.assets.PlaylistScrollbar;
	import org.flowplayer.view.AnimationEngine;
	import org.flowplayer.util.Log;
	
	//import com.hydrotik.go.HydroTween;
	
	import caurina.transitions.*;
	import caurina.transitions.properties.DisplayShortcuts;

	import mx.effects.easing.Quadratic;

	public class ScrollBar2 extends Sprite
    {
    
        protected var log:Log = new Log(this);
        private var scrollBar:DisplayObjectContainer;
        private var scrollBarThumb:MovieClip;
        private var scrollUpBtn:MovieClip;
        private var scrollTrack:MovieClip;
        private var scrollDownBtn:MovieClip;
        private var _target:Sprite;
        private var scrollBarRect:Rectangle;
        private var targetRect:Rectangle;
        private var targetHeight:Number;
        private var upper_limit:Number;
        private var range:Number;
        private var scrollBarThumbTop:Number;
        private var _scrollHeight:Number;
        private var posy:Number;
        private var posY:Number;
        private var min:Number;
        private var lastY:Number;
        private var _animationEngine:AnimationEngine;
        
        
        
        protected var scrollSpeed:Number = .1;

        
        /**
         * Constructor
         */
        public function ScrollBar2(target:Sprite, animationEngine:AnimationEngine, scrollHeight:Number, useScrollBar:Boolean = true)
        {
            _target = target;
            _scrollHeight = scrollHeight;
            _animationEngine = animationEngine;
            targetHeight = _target.height;
            targetRect = new Rectangle(0, 0, _target.width, scrollHeight);
            _target.scrollRect = targetRect;
            
         
            
            DisplayShortcuts.init();
            
            if (useScrollBar) createElements();
            
            //_target.scrollRect.y = 30*3;
            
            //addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
            
            if (targetHeight > scrollHeight && !useScrollBar){
                
                range = targetHeight - scrollHeight;
                _target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            }
            
            
        }
        
        private function scrollThumb(pos:Number):void {
        
        	Tweener.addTween(scrollBarThumb, {y:pos, time:0.2, transition:"easeOutQuad", onUpdate:function():void {
                scrollTarget();
            }});
                    
        	/*_animationEngine.animateObjectProperty(scrollBarThumb, "y", pos, 100 , function():void {
                    scrollTarget();
                    return;
                    }, Quadratic.easeOut);*/
            
        }
        
        private function scrollTarget():void {
            var p:int = ( scrollBarThumb.y - scrollTrack.y ) / range;
            var posy:int = _target.height * p;
            //var rect:Rectangle = _target.scrollRect;
            /*HydroTween.go(rect, {y:posy}, 2, 0, Quadratic.easeOut, function():void {
                  log.error(posy + "");
                    _target.scrollRect = rect;
                    return;
                    });*/
            Tweener.addTween(_target, {_scrollRect_y:int(posy), time:0.5, transition:"easeOutQuad"});
            /*
            _animationEngine.animateObjectProperty(rect, "y", posy, 1000 , function():void {
                    //scrollTarget();
                    _target.scrollRect = rect;
                    return;
                    }, Quadratic.easeOut);*/
                    
            //Tweener.addTween(_target, {_scrollRect_y:int(posy), time:0.5, transition:"easeOutQuad"});
        }
        
        
        
        /**
         * Create and initialize the slider and arrow elements.
         */
        protected function createElements():void
        {
            
            scrollBar = new PlaylistScrollbar() as DisplayObjectContainer;
            
            addChild(scrollBar);
            scrollBar.x = 0;
            scrollBar.y = 0;
            scrollBarThumb = scrollBar.getChildByName("scroller") as MovieClip;
            scrollUpBtn = scrollBar.getChildByName("upArrow") as MovieClip;
            scrollDownBtn = scrollBar.getChildByName("downArrow") as MovieClip;
            scrollTrack = scrollBar.getChildByName("track") as MovieClip;
            
            scrollUpBtn.buttonMode = true;
            scrollDownBtn.buttonMode = true;
            scrollBarThumb.buttonMode = true;
            
            var c:ColorTransform = new ColorTransform();
            c.color = 0xFFFFFF;
            
            scrollTrack.transform.colorTransform = c;
            
            
            c.color = 0xCCCCCC;
            scrollBarThumb.transform.colorTransform = c;
            
            
            //scrollTrack.transform.colorTransform.color = 0xFFFFFF;
            
            scrollBarThumb.addEventListener( MouseEvent.MOUSE_DOWN, onDragClick );
            scrollBarThumb.addEventListener(MouseEvent.MOUSE_OUT, onDragRelease); 
                    
            scrollBarThumbTop = scrollBarThumb.y;
            
            scrollBarRect = new Rectangle( scrollTrack.x, scrollTrack.y, 0, scrollTrack.height - scrollBarThumb.height );
            upper_limit = scrollTrack.y;
            range = scrollTrack.height - scrollBarThumb.height;

            
        
            scrollUpBtn.addEventListener( MouseEvent.MOUSE_DOWN, scrollUp );
            scrollDownBtn.addEventListener( MouseEvent.MOUSE_DOWN, scrollDown );
        
        }
        
        protected function scrollUp( e:MouseEvent ):void
        {
            onDragRelease(e);
            if (scrollBarThumb.y <= scrollBarThumbTop) return;
            var dir:int = 100;
            var thumbpos:Number = scrollBarThumb.y;
            thumbpos-=dir;
            scrollThumb(thumbpos);
        }
        
        protected function scrollDown( e:MouseEvent ):void
        {
            onDragRelease(e);
            if (scrollBarThumb.y > range) return;
            var dir:int = 100;
            var thumbpos:Number = scrollBarThumb.y;
            thumbpos+=dir;
            scrollThumb(thumbpos);
        }
        
        private function onDragClick( event:MouseEvent ):void {
            scrollBarThumb.addEventListener( Event.ENTER_FRAME, drag );
            scrollBarThumb.startDrag( false, scrollBarRect );
    
        }
        
        private function onDragRelease( event:MouseEvent ):void {
            scrollBarThumb.removeEventListener( Event.ENTER_FRAME, drag);
            //scrollBarThumb.stage.removeEventListener( MouseEvent.MOUSE_UP, onDragRelease);
            scrollBarThumb.stopDrag();
        }
        
        private function drag( event:Event ):void {
            scrollTarget();
        }
        
        public function mouseWheelHandler(event:MouseEvent):void {
            var thumbpos:Number;
            if (event.delta < 0) {
                if (scrollBarThumb.y < range) {
                    thumbpos = scrollBarThumb.y;
                    thumbpos-=(event.delta*2);
                    //scrollBarThumb.y-=(event.delta*2);
                    if (scrollBarThumb.y > range) {
                        thumbpos = range;
                    }
                    scrollThumb(thumbpos);
                }
            } else {
                if (scrollBarThumb.y > scrollBarThumbTop) {
                    thumbpos = scrollBarThumb.y;
                    thumbpos-=(event.delta*2);
            
                    if (scrollBarThumb.y < scrollBarThumbTop) {
                        thumbpos = scrollBarThumbTop;
                    }
                    scrollThumb(thumbpos);
                }
            }
        }


        public function onMouseMove(event:MouseEvent) : void
        {
           // _target.mouseY
            var min:Number;
            var posy:Number;
            var value:* = event;
            var event:* = value;
            min = Math.max(0, Math.min(_scrollHeight, _target.mouseY));
            posy = min - 5 * _scrollHeight - targetHeight / _scrollHeight - 25;
            if (posy != this.posY)
            {
                posy = this.posY;
                if (posy >= 0)
                {
                }
                if (posy <= Math.round(_scrollHeight - targetHeight))
                {
                    posy = Math.round(_scrollHeight - targetHeight) + 1;
                }
            }

            log.error(posy + "");
            Tweener.addTween(_target, {_scrollRect_y:int(posy), time:0.5, transition:"easeOutQuad", onUpdate:function () : void
            {
                var _loc_1:* = undefined;
                posY = (min - 5) * (_scrollHeight - targetHeight) / (_scrollHeight - 2 * 25);
                _loc_1 = Math.abs(_target.y - lastY);
                lastY = _target.y;
                return;
            }// end function
            });
            return;
        }// end function
        
        
    }
}
