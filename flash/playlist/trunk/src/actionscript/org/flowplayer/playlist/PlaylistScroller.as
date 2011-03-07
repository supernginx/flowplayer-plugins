package org.flowplayer.playlist {

    import flash.display.Sprite; 
    import flash.events.MouseEvent;
    import org.flowplayer.view.Flowplayer;
    import org.flowplayer.view.FlowStyleSheet;
    
    import org.flowplayer.model.Clip;

    import org.flowplayer.ui.buttons.ToggleButtonConfig;
    import org.flowplayer.ui.buttons.ToggleButton;

	import org.flowplayer.playlist.ui.PlaylistItemController;
	import org.flowplayer.playlist.ui.BuyButton;
	import org.flowplayer.playlist.config.Config;
	import org.flowplayer.playlist.scroller.ScrollBar2;
	import org.flowplayer.view.StyleableSprite;
	import org.flowplayer.util.TextUtil;

	import flash.text.TextField;
	import flash.net.URLRequest;
    import flash.net.navigateToURL;
	

	public class PlaylistScroller extends StyleableSprite {
		
		/*private const boxCount:int = 10;
        private const boxWidth:int = 150;
        private const boxMargin:int = 5;
        private const startPoint:int = 150;
        private const boxesWidth:int = boxCount * (boxWidth + boxMargin);
        private const endPoint:int = boxesWidth + startPoint;
        private const zeroPoint:int = boxesWidth / 2 + startPoint;*/
        
        private var buttonsContainer:Sprite;
        private var targetX:Number;
        private var speed:Number = 0;
        private var buttons:Array = [];
                
        private var verticalTransitionType:String;
        public var lastSelected:uint;
        private var direction:String;
        private var lastY:Number = 0;
    
        private var posY:Number = 0;
        private var playlistMask:Sprite;
        
        private var _player:Flowplayer;
        private var _config:Config;
        private var scrollBar:ScrollBar2;
        private var scrollHeight:Number = 150;
        private var containerWidth:Number;
        private var _style:FlowStyleSheet;
        private var scrollBarWidth:Number;
        private var _listener:Function;
        
    
        public function PlaylistScroller(player:Flowplayer, config:Config)
        {
           super("playlist-scroller", player, player.createLoader());
           
         
           rootStyle = config.canvas;
           css(style);
           
            
          // var style:Object = config.canvas;

           //_style = new FlowStyleSheet("PlaylistScroller");
           //_style.rootStyle = style;
           
           _player = player;
           _config = config;
           buildPlaylist();
        }
        
        override protected function onResize():void {
   
            log.debug("onResize() " + width + " x " + height);
     
            arrangePlaylist();
        }
        
        private function arrangePlaylist():void {
        	 
        	if (scrollBar) removeChild(scrollBar);
            
            scrollBar = new ScrollBar2(buttonsContainer, _player.animationEngine, scrollHeight, false);
            addChild(scrollBar);
            
        	for (var i:int = 0; i < buttonsContainer.numChildren; i++) { 
                Sprite(buttonsContainer.getChildAt(i)).width = width - scrollBar.width;
                
            }
            
            scrollBar.height = height;            
            scrollBar.x = buttonsContainer.x + buttonsContainer.width - 2;
            scrollBar.y = buttonsContainer.y;        	
        }
        
        private function buildPlaylist():void {
            buttonsContainer = new Sprite();
            buttonsContainer.x = 0;
            buttonsContainer.y = 0;
            addChild(buttonsContainer);

            log.error(_player.playlist.clips.length + "");
            for (var i:int = 0; i < _player.playlist.clips.length; i++) 
            {
                var clip:Clip = _player.playlist.clips[i];  
                var itemContainer:Sprite = new Sprite();
                
                //var item:PlaylistItemController = new PlaylistItemController(parseText(clip), _config.itemConfig , _player.animationEngine, style);
                var controller:PlaylistItemController = new PlaylistItemController();

                var item:ToggleButton = controller.init(_player, this, new ToggleButtonConfig(_config.iconConfig, _config.iconConfig)) as ToggleButton;

                log.error(i + "");

                item.height = 50;
                item.width = width;
                //item.height = _config.playlistDisplayProperties.heightPx;

                //item.alpha = _config.playlistDisplayProperties.alpha;
                item.alpha = 0.7;
                //item.y = (item.height * i) + 2;
                
                
                                        
                item.buttonMode = true;
                item.addEventListener(MouseEvent.CLICK,onMouseClick);
                itemContainer.addChild(item);

                /*
                if (clip.getCustomProperty("buyUrl")) {
                    var buyIcon:BuyButton = new BuyButton(_config.items, _player.animationEngine);
                    buyIcon.width = 20;
                    buyIcon.height = 20;
                    buyIcon.x = item.width - buyIcon.width - 5;
                    buyIcon.y = (item.height / 2) - (buyIcon.height / 2);
                    buyIcon.addEventListener(MouseEvent.CLICK,onBuyClick);
                    itemContainer.addChild(buyIcon);
                }    */
                
              /*  if (clip.getCustomProperty("time")) {
                	var time:TextField = TextUtil.createTextField(false, "Arial", 12);
                	time.selectable = false;
                    time.textColor = 0xFFFFFF;
                    time.htmlText = String(clip.getCustomProperty("time"));
                    itemContainer.addChild(time);
                    
                    time.y = (item.height / 2) - (time.height / 2);
                    if (buyIcon) {
                    	time.x = buyIcon.x - time.width - 5;
                    } else {
                    	time.x = item.width - time.width - 5;
                    }
                	
                }*/
                
                buttonsContainer.addChild(itemContainer);
                itemContainer.y = (item.height * i) + 2;
            }  
           
        }
        
        private function parseText(clip:Clip):String {
            var content:String = _config.itemTemplate;
            
            for (var key:String in clip.customProperties) {
                content = content.replace("$\{" +key+ "\}", clip.customProperties[key]);
            }
            
            content = "<span=\"item\">" + content + "</span>";
            
            
            return content;
        }
       
        private function toggleOff(index:Number):void {
        	for (var i:int = 0; i < buttonsContainer.numChildren; i++) { 
               // if (i != index) PlaylistItemController(Sprite(buttonsContainer.getChildAt(i)).getChildAt(0)).reset();
            }
        }
        
        private function onBuyClick(event:MouseEvent):void {
        	var item:Sprite = event.currentTarget as Sprite;
        	var index:Number = buttonsContainer.getChildIndex(item.parent);
            //log.error(_player.playlist.getClip(index).getCustomProperty("buyUrl") + "");
            
            var request:URLRequest = new URLRequest(String(_player.playlist.getClip(index).getCustomProperty("buyUrl")));
            navigateToURL(request, "_blank");
        }
        
        private function onMouseClick(event:MouseEvent):void {
        	//var item:Sprite = event.currentTarget as Sprite;
             log.error("clicked");
            //var index:Number = buttonsContainer.getChildIndex(item.parent);
           
            
            //toggleOff(index);
            //_listener();
           //_player.stop();
           //_player.playlist.toIndex(index);

           //_player.play();
        
        }
        
        public function onPlaylistChange(listener:Function):void {
            _listener = listener;
        }
  
/*
        public function onMouseMove(event:MouseEvent):void {
            scrollVertical(event);
            return;
        }
    
        private function scrollVertical(event:MouseEvent):void {
            var min:Number = Math.max(0, Math.min(playlistMask.height, mouseY));
            var posy:Number = (buttonsContainer.getChildAt(0).height) * (playlistMask.height - buttonsContainer.height) / (playlistMask.height - buttonsContainer.getChildAt(buttonsContainer.numChildren - 1).height);
            if (posy != posY){
                posy = posY;
                if (posy >= 0) {
                    posy;
                }
                if (posy <= Math.round(playlistMask.height - buttonsContainer.height)) {
                    posy = Math.round(playlistMask.height - buttonsContainer.height) + 1;
                }
                
                 _player.animationEngine.animate(buttonsContainer, { y: int(posy)}, 500 , function():void {
                    posY = (min - buttonsContainer.getChildAt(0).height) * (playlistMask.height - buttonsContainer.height) / (playlistMask.height - 2 * buttonsContainer.getChildAt(buttonsContainer.numChildren - 1).height);
                    lastY = buttonsContainer.y;
                    return;
                    }, Quadratic.easeOut);
            }
        }
        */
        /*
        private function scrollHorizontal(event:MouseEvent):void {
            var min:Number;
            var posy:Number;
            var event:* = event;
            min = Math.max(0, Math.min(playlistMask.width, mouseX));
            posy = (min - buttons[0].width) * (playlistMask.width - buttonsContainer.width) / (playlistMask.width - buttons[buttons.length - 1].width);
            if (posy != posY) {
                posy = posY;
                if (posy >= 0) {
                    posy;
                }
                
                if (posy <= Math.round(playlistMask.width - buttonsContainer.width)) {
                    posy = Math.round(playlistMask.width - buttonsContainer.width) + 1;
                }
                
         
            }
        }*/
        
	}
}
