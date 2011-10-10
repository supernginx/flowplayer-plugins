/*
 * flowplayer.playlist @VERSION. Flowplayer JavaScript plugin.
 * 
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Author: Tero Piirainen, <info@flowplayer.org>
 * Copyright (c) 2008-2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */

 (function($) {
	
	$f.addPlugin("playlist", function(wrap, options) {


		// self points to current Player instance
		var self = this;	
		
		var opts = {
			playingClass: 'playing',
			pausedClass: 'paused',
			progressClass:'progress',
			stoppedClass:'stopped',
			template: '<a href="${url}">${title}</a>',
			loop: false,
            continuousPlay: false,
			playOnClick: true,
			manual: false
		};
		
		$.extend(opts, options);


        //use continous play or loop option #361
        opts.loop = opts.continuousPlay || opts.loop;

		wrap = $(wrap);

        //#399 Do not try to auto detect manual playlist as element could be an inline playlist template. Specify manual playlist by the config instead.
        var manual = (self.getPlaylist().length <= 1) || opts.manual;
        var els = null;


		
		
//{{{ "private" functions
				
		function toString(clip) {
			var el = template;
			
			$.each(clip, function(key, val) {	
				if (!$.isFunction(val)) {
					el = el.replace("$\{" +key+ "\}", val).replace("$%7B" +key+ "%7D", val);			
				}
			}); 
			return el;
		}
		
		// assign onClick event for each clip
		function bindClicks() {			
			els = getEls().unbind("click.playlist").bind("click.playlist", function() {
				return play($(this), els.index(this));						
			});		
		}
		
		function buildPlaylist() {
			wrap.empty();
			
			$.each(self.getPlaylist(), function() {  
				wrap.append(toString(this)); 
			});				
			
			bindClicks();
		} 

		
		function play(el, clip)  {
			if (el.hasClass(opts.playingClass) || el.hasClass(opts.pausedClass)) {
				self.toggle();
			} else {
				el.addClass(opts.progressClass);
				self.play(clip); 							
			}			
			
			return false;
		}	
		
		
		function clearCSS() {
			if (manual) { els = getEls(); }
			els.removeClass(opts.playingClass);
			els.removeClass(opts.pausedClass);
			els.removeClass(opts.progressClass);
			els.removeClass(opts.stoppedClass);		
		}
		
		function getEl(clip) {
            //fix for #366 need double quotes for selector
			return (manual) ? els.filter("[href=\"" + clip.originalUrl + "\"]") : els.eq(clip.index);
		}
		
		function getEls() {
			var els = wrap.find("a");
			return els.length ? els : wrap.children();
		}
//}}}  
		 
		/* setup playlists with onClick handlers */ 
		
		// internal playlist
		if (!manual) {

			var template = wrap.is(":empty") ? opts.template : wrap.html();
			buildPlaylist();
			
			
		// manual playlist
		} else {

			// allows dynamic addition of elements
			if ($.isFunction(els.live)) {
				var foo = $(wrap.selector + " a");
				if (!foo.length) { foo = $(wrap.selector + " > *"); }
				
				foo.live("click", function() {
					var el = $(this);
					return play(el, el.attr("href"));
				});
				
			} else {
				els.click(function() {
					var el = $(this);
					return play(el, el.attr("href"));
				});					
			}

            //#368 configure manual playlists as flowplayer playlist items to repeat and transition correctly.
			var playlist = [];

            $.each(els, function(key, value) {
                 playlist.push({ url: ($(value).attr("href")) });
			});

            self.onLoad(function() {
                self.setPlaylist(playlist);
            });

            //#368 this is required for the ipad plugin to function.
            var clip = self.getClip(0);

			if (!clip.url && opts.playOnClick) {
				clip.update({url: escape(els.eq(0).attr("href"))});
			}
		}
		
		// onBegin
		self.onBegin(function(clip) {
			clearCSS();		
			getEl(clip).addClass(opts.playingClass);
		});	
		
		// onPause	
		self.onPause(function(clip) {
			getEl(clip).removeClass(opts.playingClass).addClass(opts.pausedClass);		
		});	
		
		// onResume
		self.onResume(function(clip) {
			getEl(clip).removeClass(opts.pausedClass).addClass(opts.playingClass);		
		});		
		
		// what happens when clip ends ?
		if (!opts.loop && !manual) {
			
			// stop the playback exept on the last clip, which is stopped by default
			self.onBeforeFinish(function(clip) {
				getEl(clip).removeClass(opts.playingClass);
				getEl(clip).addClass(opts.stoppedClass);
				if (!clip.isInStream && clip.index < els.length -1) {
					return false;
				}
			}); 
		}
		
		// onUnload
		self.onUnload(function() {
			clearCSS();		
		});
		
		// onPlaylistReplace
		if (!manual) {
			self.onPlaylistReplace(function() {
				buildPlaylist();		
			});
		}
		
		// onClipAdd
		self.onClipAdd(function(clip, index) {	
			els.eq(index).before(toString(clip));			
			bindClicks(); 
		});		
		
		return self;
		
	});
		
})(jQuery);		
