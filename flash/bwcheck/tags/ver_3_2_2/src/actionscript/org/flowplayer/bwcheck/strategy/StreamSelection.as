/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Daniel Rossi, <electroteque@gmail.com>
 * Copyright (c) 2009 Electroteque Multimedia
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
 
package org.flowplayer.bwcheck.strategy {

	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.model.BitrateItem;

	/**
	 * @author danielr
	 */
	internal interface StreamSelection {
		
		function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number

        function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):BitrateItem
        
        function getDefaultStream(bitrateProperties:Array, player:Flowplayer):BitrateItem

	}
}
