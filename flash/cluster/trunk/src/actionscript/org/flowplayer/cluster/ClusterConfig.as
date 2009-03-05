/* * This file is part of Flowplayer, http://flowplayer.org * * By: Daniel Rossi, <electroteque@gmail.com> * Copyright (c) 2008 Electroteque Multimedia * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.cluster {			public class ClusterConfig {				/**		 * @author api		 */		private var _encoding:Number = 0;				/**		 * Hosts IP Array List For Fallback and Round Robin Systems		 * 		 * @private		 * @default	null		 */		private var _hosts:Array = new Array();				/** 		 * Connect Attempt Retry Timer Timeout in milliseconds		 * 		 * @private		 * @default	5000		 */			 		private var _connectTimeout:Number = 5000;				private var _connectCount:Number = 3;				private var _loadBalanceServers:Boolean = false;				private var _failureExpiry:int = 0;				private var _connectionArgs:* = null;				private var _serverType:String = "red5";				public function set connectionArgs(args:*):void		{			_connectionArgs = args;		}				public function get connectionArgs():*		{			return _connectionArgs;		}				public function set encoding(encoding:Number):void		{			_encoding = encoding;		}				public function get encoding():Number		{			return _encoding;		}				public function set hosts(hosts:Array):void		{			_hosts = hosts;		}				public function get hosts():Array		{			return _hosts;		}				public function set connectTimeout(timeout:Number):void		{			_connectTimeout = timeout;		}				public function get connectTimeout():Number		{			return _connectTimeout;		}				public function set connectCount(count:Number):void		{			_connectCount = count;		}				public function get connectCount():Number		{			return _connectCount;		}				public function set loadBalanceServers(value:Boolean):void		{			_loadBalanceServers = value;		}				public function get loadBalanceServers():Boolean		{			return _loadBalanceServers;		}				public function set failureExpiry(expiry:Number):void		{			_failureExpiry = expiry;		}				public function get failureExpiry():Number		{			return _failureExpiry;		}				public function set serverType(value:String):void		{			_serverType = value;		}				public function get serverType():String		{			return _serverType;		}	}}