/* * This file is part of Flowplayer, http://flowplayer.org * * By: Daniel Rossi, <electroteque@gmail.com>, Anssi Piirainen Flowplayer Oy * Copyright (c) 2009 Electroteque Multimedia, Flowplayer Oy * * Released under the MIT License: * http://www.opensource.org/licenses/mit-license.php */package org.flowplayer.bwcheck {	import org.flowplayer.model.PluginFactory;			import flash.display.Sprite;		/**	 * @author api	 */	public class BwPlugin extends Sprite implements PluginFactory {		public function BwPlugin() {		}		/**		 * A factory method to create the provider.		 */		public function newPlugin():Object {			return new BwProvider();		}	}}