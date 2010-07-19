/* * This file is part of Flowplayer, http://flowplayer.org * * By: Anssi Piirainen, <support@flowplayer.org> * Copyright (c) 2008, 2009 Flowplayer Oy * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */ package org.flowplayer.pseudostreaming {	/**	 * @author api	 */		import flash.system.Capabilities;		public class Config {				private var _queryString:String = "start=${start}";		private var _enableRangeRequests:Boolean;				public function get queryString():String {			return _queryString;		}				public function set queryString(queryString:String):void {			_queryString = queryString;		}				public function set enableRangeRequests(value:Boolean):void {            _enableRangeRequests = value;        }        public function get enableRangeRequests():Boolean {            return Capabilities.version.split(' ')[1].split(",")[0] >= 10             && Capabilities.version.split(' ')[1].split(",")[1] >=1             && _enableRangeRequests;        }	}}