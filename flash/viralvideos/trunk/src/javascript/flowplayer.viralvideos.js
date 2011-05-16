/**
 * flowplayer.viralvideos 3.2.6. Flowplayer JavaScript plugin.
 * 
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Author: TDan Rossi, <electroteque@gmail.com>
 * Copyright (c) 2008-2010 Flowplayer Ltd
 *
 * Dual licensed under MIT and GPL 2+ licenses
 * SEE: http://www.opensource.org/licenses
 * 
 *
 *
 */ 
(function($) {
	
	$f.addPlugin("viralvideos", function(options) {


		// self points to current Player instance
		var self = this;	
		
		var opts = {
			pluginName: "viral",
			splashImage: ""
		};		
		
		$.extend(opts, options);
		wrap = $(wrap);		
		var manual = self.getPlaylist().length <= 1 || opts.manual; 
		var els = null;

	
		self.onBeforeBegin(function(clip) {
			var url = self.getPlugin(opts.pluginName).getPlayerSwfUrl() + "?config=" + self.getPlugin(opts.pluginName).getEmbedConfig(true);
			var videoSrc = "<link rel=\"video_src\" href=\"" + url + "\"/>";
			$('head').append("<meta name=\"video_type\" content=\"application/x-shockwave-flash\" />");
			$('head').append("<meta name=\"video_weight\" content=\""+self.getClip().weight+"\" />");
			$('head').append("<meta name=\"video_height\" content=\""+self.getClip().height+"\" />");
			$('head').append("<meta name=\"video_type\" content=\"application/x-shockwave-flash\" />");
			
			$('head').append(videoSrc);
			
			
			
			if (opts.splashImage) {
				var imageSrc = "<link rel=\"image_src\" href=\"" + opts.splashImage + "\"/>";
			}
	
		
		});	
		
		
		
		return self;
		
	});
		
})(jQuery);		
