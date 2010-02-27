/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.flowplayer.shareembed {

    import com.adobe.serialization.json.JSON;
	
	import flash.display.Stage;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    
	import org.flowplayer.controller.ResourceLoader;
    import org.flowplayer.model.ClipEvent;
    import org.flowplayer.model.DisplayPluginModel;
    import org.flowplayer.model.Plugin;
    import org.flowplayer.model.PluginModel;
    import org.flowplayer.view.FlowStyleSheet;
    import org.flowplayer.view.Styleable;
    import org.flowplayer.model.PlayerEvent;
    import org.flowplayer.util.PropertyBinder;
    import org.flowplayer.view.AbstractSprite;
    import org.flowplayer.view.Flowplayer;
    
    import org.flowplayer.util.URLUtil;
    
    import org.flowplayer.shareembed.assets.EmailBtn;
    import org.flowplayer.shareembed.assets.EmbedBtn;
    import org.flowplayer.shareembed.assets.ShareBtn;
	
	import flash.text.AntiAliasType;
	import flash.text.TextField;


	/**  
	 * @author danielr
	 */
	public class ShareEmbed extends AbstractSprite implements Plugin, Styleable {
		
		public var _player:Flowplayer;
		private var _model:PluginModel;
		private var _config:Config;
		private var _loader:ResourceLoader;


		private var embedBtn:Sprite;
		private var emailBtn:Sprite;
		private var shareBtn:Sprite;
		private var btnContainer:Sprite;
		
		private var _embedView:EmbedView;
		private var _emailView:EmailView;
		private var _shareView:ShareView;
		private var _panelContainer:Sprite;

		public var _embedTab:Tab;
		public var _emailTab:Tab;
		public var _shareTab:Tab;
		public var _tabContainer:Sprite;

		private var _stageWidth:int;
		private var _stageHeight:int;
		
		private var _stage:Stage;
		
		private var _displayButtons:Boolean;
		
		
		public var field:TextField;
		private var _emailMask:Sprite = new Sprite();
		private var _embedMask:Sprite = new Sprite();
		private var _shareMask:Sprite = new Sprite();
		
		private var curBorderSize:int = 1 // _model.config.style.border
		
		private var tmpx:int = 10;
		private var tmpy:int = 0;
		
		private var tmpTabHeight:int = 20;
		private var tmpTabWidth:int = 100;
		
		private var tmpTabHeightLive:int = 20 + (curBorderSize);
		
		private var basicBGG:Array;

		/**
		 * Sets the plugin model. This gets called before the plugin
		 * has been added to the display list and before the player is set.
		 * @param plugin
		 */
		public function onConfig(plugin:PluginModel):void {
			_model = plugin;
			//_config = new PropertyBinder(new Config(), null).copyProperties(plugin.config) as Config;	
			_config = new PropertyBinder(new Config(), null).copyProperties(_model.config) as Config;	
		}
		
		override protected function onResize():void {
        }


		public function onLoad(player:Flowplayer):void {
			_player = player;
			
			_player.playlist.onBegin(onBegin);
			_player.playlist.onLastSecond(onBeforeFinish);

			_stageWidth = _player.playlist.current.width
			_stageHeight = _player.playlist.current.height
			
			_loader = _player.createLoader();
			
			field = _player.createTextField();
			field.width = this.width - 20;
            field.selectable = false;            
            field.height = 20;   
            field.width = 400;   
			field.y = -10
			field.antiAliasType = AntiAliasType.ADVANCED;

			addChild(field);
			
			_stageWidth = _player.playlist.current.width
			_stageHeight = _player.playlist.current.height
			

			
			_panelContainer = new Sprite();
			btnContainer = new Sprite();
			
			//enable email icon / panel
			if (_config.enableEmail) {
	            emailBtn = new EmailBtn() as Sprite;
	            btnContainer.addChild(emailBtn);
	            emailBtn.y = 0;
			}
            
            //enable embed icon / panel
            if (_config.enableEmbed) {
	            embedBtn = new EmbedBtn() as Sprite;
	            btnContainer.addChild(embedBtn);
	            embedBtn.y = emailBtn.y + emailBtn.height + 5;
            }
            
            //enable share icon / panel
            if (_config.enableShare) {
	            shareBtn = new ShareBtn() as Sprite;
	            btnContainer.addChild(shareBtn);
	            shareBtn.y = embedBtn.y + embedBtn.height + 5;
            }
            
            _player.addToPanel(btnContainer, {right:10, top: 0, zIndex: 100, alpha: 0});
			addChild(_panelContainer)
 			//setupTabs("Email");
			_tabContainer = new Sprite();

			_tabContainer.alpha = 0;
           
            emailBtn.addEventListener(MouseEvent.CLICK, onShowEmailPanel);
			embedBtn.addEventListener(MouseEvent.CLICK, onShowEmbedPanel);
			shareBtn.addEventListener(MouseEvent.CLICK, onShowSharePanel);
			
			_displayButtons = true;

            _model.dispatchOnLoad();
        }
        
		public function getDefaultConfig():Object {
			//return {width: "80%"};
			return {
				top: 10, 
				left: 10, 
				backgroundColor: '#202c31',
				backgroundGradient: [0.0, 0.7],
				opacity: 1,
				borderRadius: 10,
				border: 'none',
				width: "100%", 
				height: "100%"
			};
		}

		//Javascript API functions
		
		/**
		 * Setup the email panel
		 * 
		 * @return void
		 */
		[External]
		public function email():void {
			setupTabs('Email');
			if (_emailView) {
				showPanels("Email");
			} else {
				_emailView = new EmailView(_model as DisplayPluginModel, _player, _config);
				//_emailView.setSize(stage.width, stage.height);
				_emailView.style = createStyleSheet(null);
				_panelContainer.addChild(_emailView);
			}
			_emailView.setSize(_stageWidth-20, _stageHeight-50);
			_emailView.x = 0;
			_emailView.y = 20;
		}
		
		/**
		 * Setup the embed panel
		 * 
		 * @return void
		 */
		[External]
        public function embed():void {
			setupTabs('Embed');
			if (_embedView) {
				showPanels("Embed");
			} else {
				_embedView = new EmbedView(_model as DisplayPluginModel, _player);
				//_embedView.setSize(stage.width, stage.height);
				_embedView.style = createStyleSheet(null);
				_panelContainer.addChild(_embedView);
				//get the embed code and return it to the embed code textfield
				_embedView.html = getEmbedCode().replace(/\</g, "&lt;").replace(/\>/g, "&gt;");
			}
			_embedView.setSize(_stageWidth-20, _stageHeight-50);
			_embedView.x = 0;
			_embedView.y = 20;
       }
        
        
        /**
		 * Setup the share panel
		 * 
		 * @return void
		 */
        [External]
        public function share():void {
			setupTabs('Share');
			if (_shareView) {
				showPanels("Share");
			} else {
				_shareView = new ShareView(_model as DisplayPluginModel, _player, _config);
				//return the embed code to be used for some of the social networking site links like myspace
				_shareView.embedCode = getEmbedCode();
				_shareView.style = createStyleSheet(null);
				_panelContainer.addChild(_shareView);
			}
			_shareView.setSize(_stageWidth-20, _stageHeight-50);
			_shareView.x = 0;
			_shareView.y = 20;
		}
		
		public function showPanels(whichPanel:String):void {
			setLiveTab(whichPanel)
			if(whichPanel == "Email") _emailView.alpha = 1;
			if(whichPanel == "Embed") _embedView.alpha = 1;
			if(whichPanel == "Share") _shareView.alpha = 1;
			_tabContainer.y = 0;
			_panelContainer.y = 0;
		}
		
		public function hideAllPanels ():void {
			if (_emailView) _emailView.y = -5000;
			if (_embedView) _embedView.y = -5000;
			if (_shareView) _shareView.y = -5000;
		}
		
		public function removeTabs():void {
			_player.animationEngine.fadeOut(_tabContainer, 500, tabsFadedOut);
		}
		private function tabsFadedOut():void {
			_tabContainer.y = -5000;
			_panelContainer.y = -5000;
		}
		
		private function setLiveTab(newTab:String):void {
			if (basicBGG == null && _emailView) basicBGG = _emailTab.style.backgroundGradient;
			if (basicBGG == null && _embedView) basicBGG = _emailTab.style.backgroundGradient;
			if (basicBGG == null && _shareView) basicBGG = _emailTab.style.backgroundGradient;
			
			if (_emailView) {
				_emailMask.height = tmpTabHeight; 
				_emailTab.setCSS({backgroundGradient: basicBGG})
			}
			if (_embedView) {
				_embedMask.height = tmpTabHeight;
				_embedTab.setCSS({backgroundGradient: basicBGG})
			}
			if (_shareView) {
				_shareMask.height = tmpTabHeight;
				_shareTab.setCSS({backgroundGradient: basicBGG})
			}
			
			
			if (newTab == "Email") { 
				_emailMask.height = tmpTabHeightLive;
				_emailTab.setCSS({backgroundGradient: 'none'})
			}
			if (newTab == "Embed") {
				_embedMask.height = tmpTabHeightLive;
				_embedTab.setCSS({backgroundGradient: 'none'})
			}
			if (newTab == "Share") {
				_shareMask.height = tmpTabHeightLive;
				_shareTab.setCSS({backgroundGradient: 'none'})
			}
			
		}
		public function switchTabs(newTab:String):void {
			hideAllPanels();
			setLiveTab(newTab);
			
			if (newTab == "Email") { 
				email();
			}
			if (newTab == "Embed") {
				embed();
			}
			if (newTab == "Share") {
				share();
			}
		}
		
		private function setupTabs(liveTab:String):void {
			if (_shareTab || _emailTab || _embedTab) {
				_tabContainer.alpha = 1;
				_tabContainer.x = 0;
			} else {
				
				var masky:int = tmpy - (curBorderSize / 2);
				var maskx:int = tmpx - curBorderSize;
				if (_config.enableEmail) {
					_emailTab = new Tab(_model as DisplayPluginModel, _player, "Email");
					_emailTab.setSize(tmpTabWidth, tmpTabHeight*2);
					_emailTab.y = tmpy;
					_emailTab.x = tmpx;
					_emailTab.style = createStyleSheet(null);
					_tabContainer.addChild(_emailTab);
					
					_tabContainer.addChild(_emailMask)
					_emailMask.graphics.beginFill(0xffffff, 1);
					if (liveTab == "Email") {
						_emailMask.graphics.drawRect(0, 0, tmpTabWidth + (curBorderSize * 2), tmpTabHeightLive);
					} else {
						_emailMask.graphics.drawRect(0, 0, tmpTabWidth + (curBorderSize * 2), tmpTabHeight);
					}
					_emailMask.graphics.endFill();
					_emailMask.x = tmpx - (curBorderSize / 2);
					_emailMask.y = masky;
					_emailTab.mask = _emailMask;
					
					
					tmpx += tmpTabWidth + (curBorderSize * 2);
				}
				if (_config.enableEmbed) {
					_embedTab = new Tab(_model as DisplayPluginModel, _player, "Embed");
					_embedTab.setSize(tmpTabWidth, tmpTabHeight*2);
					_embedTab.y = tmpy;
					_embedTab.x = tmpx;
					_embedTab.style = createStyleSheet(null);
					_tabContainer.addChild(_embedTab);
					
					_tabContainer.addChild(_embedMask)
					_embedMask.graphics.beginFill(0xffffff, 1);
					if (liveTab == "Embed") {
						_embedMask.graphics.drawRect(0, 0, tmpTabWidth + (curBorderSize * 2), tmpTabHeightLive);
					} else {
						_embedMask.graphics.drawRect(0, 0, tmpTabWidth + (curBorderSize * 2), tmpTabHeight);
					}
					_embedMask.graphics.endFill();
					_embedMask.x = tmpx - (curBorderSize / 2);
					_embedMask.y = masky;
					_embedTab.mask = _embedMask;
					
					
					tmpx += tmpTabWidth + (curBorderSize * 2);
				}
				if (_config.enableShare) {
					_shareTab = new Tab(_model as DisplayPluginModel, _player, "Share");
					_shareTab.setSize(100, tmpTabHeight*2);
					_shareTab.y = 0;
					_shareTab.x = tmpx;
					_shareTab.style = createStyleSheet(null);
					_tabContainer.addChild(_shareTab);
					
					_tabContainer.addChild(_shareMask)
					_shareMask.graphics.beginFill(0xffffff, 1);
					if (liveTab == "Share") {
						_shareMask.graphics.drawRect(0, 0, tmpTabWidth + (curBorderSize * 2), tmpTabHeightLive);
					} else {
						_shareMask.graphics.drawRect(0, 0, tmpTabWidth + (curBorderSize * 2), tmpTabHeight);
					}
					_shareMask.graphics.endFill();
					_shareMask.x = tmpx - (curBorderSize / 2);
					_shareMask.y = masky;
					_shareTab.mask = _shareMask;
					
					
					tmpx += tmpTabWidth + (curBorderSize * 2);
				}
				_tabContainer.alpha = 1;
				_tabContainer.x = 0;

				addChild(_tabContainer);
			}
			setLiveTab(liveTab);


		}
        
        /**
		 * Get the embed code obtained from the root config flashvar
		 * We need to remove some config objects when sharing, like the email script urls etc 
		 * 
		 * @return String
		 */
        private function getEmbedCode():String
        {
   			
        	var conf:Object = JSON.decode(stage.loaderInfo.parameters["config"]);
			
			//loop through the plugins and replace the plugin urls with absolute full domain urls
			for (var plugin:String in conf.plugins)
        	{
        		var url:String = URLUtil.isCompleteURLWithProtocol(conf.plugins[plugin].url) 
        						? conf.plugins[plugin].url 
        						: conf.plugins[plugin].url.substring(conf.plugins[plugin].url.lastIndexOf("/") + 1,conf.plugins[plugin].url.length);
        						
        		conf.plugins[plugin].url = URLUtil.completeURL(_config.baseURL, url);
        	}
        	
        	
        	//remove the email script url
        	conf.plugins[_model.name].emailScriptURL = null;
        	//remove the email script token url
        	conf.plugins[_model.name].emailScriptTokenURL = null;
        	//remove the email script token
        	conf.plugins[_model.name].emailScriptToken = null;
        	
        	//remove the playerId config
        	conf.playerId = null;
			
			//get the flowplayer name
        	var playerSwf:String = URLUtil.completeURL(URLUtil.pageUrl, _player.config.playerSwfName);
       		
       		var configStr:String = JSON.encode(conf);
        	
        	var code:String = 
        	'<object id="' + _player.id + '" width="' + stage.width + '" height="' + stage.height +'" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"> ' + "\n" +
			'	<param value="true" name="allowfullscreen"/>' + "\n" +
			'	<param value="always" name="allowscriptaccess"/>' + "\n" +
			'	<param value="high" name="quality"/>' + "\n" +
			'	<param value="true" name="cachebusting"/>' + "\n" +
			'	<param value="#000000" name="bgcolor"/>' +  "\n" +
			'	<param name="movie" value="' + playerSwf + '" />' + "\n" +
			'	<param value="config=' + configStr + '" name="flashvars"/>' + "\n" +
			'	<embed src="' + playerSwf + '" type="application/x-shockwave-flash" width="' + stage.width + '" height="' + stage.height +'" allowfullscreen="true" allowscriptaccess="always" cachebusting="true" flashvars="config=' + configStr + '" bgcolor="#000000" quality="true"/>' + "\n" +
			'</object>';
			
			return code;
        }
        
        private function createStyleSheet(cssText:String = null):FlowStyleSheet {
			
			var styleSheet:FlowStyleSheet = new FlowStyleSheet("#content", cssText);
			// all root style properties come in config root (backgroundImage, backgroundGradient, borderRadius etc)
			addRules(styleSheet, _model.config);
			// style rules for the textField come inside a style node
			addRules(styleSheet, _model.config.style);
			return styleSheet;
		}
		
		private function addRules(styleSheet:FlowStyleSheet, rules:Object):void {
			var rootStyleProps:Object;
			for (var styleName:String in rules) {
				log.debug("adding additional style rule for " + styleName);
				if (FlowStyleSheet.isRootStyleProperty(styleName)) {
					if (! rootStyleProps) {
						rootStyleProps = new Object();
					}
                    log.debug("setting root style property " + styleName + " to value " + rules[styleName]);
					rootStyleProps[styleName] = rules[styleName];
				} else {
					styleSheet.setStyle(styleName, rules[styleName]);
				}
			}
			styleSheet.addToRootStyle(rootStyleProps);
		}
		
		/**
		 * Show the icon buttons panel
		 */
		private function showButtonPanel():void
		{	
			hideAllPanels();
			_tabContainer.alpha = 0;

			_player.animationEngine.animate(btnContainer,{alpha: 1}, 500);
			//field.htmlText = ""
		}
		
		/**
		 * Hide the icon buttons panel
		 */
		private function hideButtonPanel():void
		{	
			_player.animationEngine.animate(btnContainer,{alpha: 0}, 500);
		}
		
		private function onMouseOver(event:PlayerEvent):void
        {
			if (_displayButtons) {
				showButtonPanel();
			}
        }
        
        private function onMouseOut(event:PlayerEvent):void
        {
			hideButtonPanel();
        }
		
		private function onBegin(event:ClipEvent):void
		{
			hideButtonPanel();
			
			_stageWidth = stage.width;
			_stageHeight = stage.height;
			_stage = stage;
			
			_player.onMouseOver(onMouseOver);
			_player.onMouseOut(onMouseOut);
		}
		
		/**
		 * Show the icon buttons panel when the video is complete
		 */
		private function onBeforeFinish(event:ClipEvent):void
		{
			showButtonPanel();
		}
		
		private function onShowEmailPanel(event:MouseEvent):void
		{
			email();
			_displayButtons = false;
			displayButtons(false);
		}
		
		private function onShowEmbedPanel(event:MouseEvent):void
		{
			embed();
			_displayButtons = false;
			displayButtons(false);
		}
		
		private function onShowSharePanel(event:MouseEvent):void
		{
			share();
			_displayButtons = false;
			displayButtons(false);
		}
		
		public function displayButtons (display:Boolean):void {
			if (display) {
				_displayButtons = true;
				showButtonPanel();
			} else {
				_displayButtons = false;
				hideButtonPanel();
			}
		}
		
		[External]
        public function show():void
        {
			if (_displayButtons) {
				showButtonPanel();
			}
        }
		
		public function css(styleProps:Object = null):Object {
			return {};
		}
		
		public function animate(styleProps:Object):Object {
			return {};
		}
		
		
		
	}
}
