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
	import flash.system.System;
	import org.flowplayer.model.DisplayPluginModel;
	import org.flowplayer.view.FlowStyleSheet;
	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.view.StyleableSprite;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;	

	import flash.text.AntiAliasType;


	/**
	 * @author danielr
	 */
	internal class Tab extends StyleableSprite {

		private var _htmlText:String;
		private var _player:Flowplayer;
		private var _plugin:DisplayPluginModel;
		
		private var _xPadding:int = 5;
		
		public var field:TextField
		
		public function Tab(plugin:DisplayPluginModel, player:Flowplayer, mytext:String) {
			super(null, player, player.createLoader());
			_plugin = plugin;
			_player = player;
			_htmlText = mytext;
			
		}
		
		public function setCSS(styleObj:Object):void {
			this.css(styleObj);
		}
		
		override protected function onSetStyle(style:FlowStyleSheet):void {
			log.debug("onSetStyle");
			createTextField(_htmlText);
		}

		override protected function onSetStyleObject(styleName:String, style:Object):void {
			log.debug("onSetStyleObject");
			createTextField(_htmlText);
		}

		
		public function get html():String {
			return _htmlText;
		}
		
		

		private function createTextField(htmlText:String):void {
			log.debug("creating text field for text " + htmlText);
			if (field) {
				removeChild(field);
			} 
			
			
			field = _player.createTextField();
			field.width = this.width - 20;
            field.selectable = false;            
            field.height = 20;            
            field.x = 5;      
			field.antiAliasType = AntiAliasType.ADVANCED;

            field.htmlText = htmlText;
			addChild(field);
			this.addEventListener(MouseEvent.CLICK, onThisClicked);
			
		}
		
	

		override protected function onResize():void {
			this.x = 0;
			this.y = 0;
		}

		override protected function onRedraw():void {
		
		}		
		
		public function onThisClicked(event:MouseEvent):void {
			ShareEmbed(_plugin.getDisplayObject()).switchTabs(_htmlText);
		}
		public function closePanel():void {
			_player.animationEngine.fadeOut(this, 0, closePanel2);	
		}
		public function closePanel2():void {
			ShareEmbed(_plugin.getDisplayObject()).removeChild(this);
		}

	}
}
