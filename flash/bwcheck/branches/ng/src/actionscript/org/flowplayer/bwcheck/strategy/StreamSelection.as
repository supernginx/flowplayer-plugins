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
	import org.osmf.net.DynamicStreamingItem;
	import __AS3__.vec.Vector;

	/**
	 * @author danielr
	 */
	public interface StreamSelection {
		
		function getStreamIndex(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):Number

        function getStream(bandwidth:Number, bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem
        
        function getDefaultStream(bitrateProperties:Vector.<DynamicStreamingItem>, player:Flowplayer):DynamicStreamingItem

	}
}
