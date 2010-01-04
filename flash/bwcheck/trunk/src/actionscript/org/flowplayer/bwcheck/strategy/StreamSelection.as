package org.flowplayer.bwcheck.strategy {

	import org.flowplayer.view.Flowplayer;
	import org.flowplayer.bwcheck.Bitrate;

	internal interface StreamSelection {
		
		function getStreamIndex(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Number
		function getStream(bandwidth:Number, bitrateProperties:Array, player:Flowplayer):Bitrate
		
	}
}
