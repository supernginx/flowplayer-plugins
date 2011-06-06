/**
 * flowplayer.bitrateselect.js Flowplayer JavaScript plugin.
 *
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * Authors:
 *   Daniel Rossi, danielr@electroteque.org
 *   Anssi Piirainen, api@iki.fi
 *
 * Copyright (c) 2011 Flowplayer Ltd
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 */
(function($) {

	$f.addPlugin("bitrateselect", function(container, options) {

		// self points to current Player instance
		var self = this;

		var opts = {
			selectedBitrateClass: 'bitrate-selected',
			pluginName: 'bitrateselect',
			templateId: null,
			fadeTime: 500
		};

		$.extend(opts, options);

		var wrap = container;

        // use either the element with templateId or the contents of wrap
		var template = opts.templateId ? $('<div>').append($(opts.templateId).clone()).remove().html() : $(wrap).html();

		var plugin = self.getPlugin(opts.pluginName) || null;

		function parseTemplate(values) {
			var el = template;

			$.each(values, function(key, val) {
				if (key=="bitrate" && !values.label) {
					el = el.replace("\{label\}", val + " k").replace("%7B" +key+ "%7D", val + " k");
				}
				el = el.replace("\{" +key+ "\}", val).replace("%7B" +key+ "%7D", val);
			});
			return el;
		}

        function play(bitrate)  {
            if (!plugin) return false;
            plugin.setBitrate(bitrate);
            return false;
        }

        function setActiveOption(el) {
            wrap.children().removeClass(opts.selectedBitrateClass);
            el.addClass(opts.selectedBitrateClass);
        }

		function buildBitrateList() {
			wrap.fadeOut(opts.fadeTime).empty();
			var containerWidth = $("#" + self.id()).width();
			var index = 0;
			var clip = self.getClip();

            $.each(clip.bitrates, function() {
                var el = parseTemplate(this);
				
                el = $(el);
                el.attr("index", this.bitrate);
                el.show();
                el.click(function() {
                    setActiveOption(el);
                    play($(this).attr("index"));
                    if ($(this).is('a')) return false;
                });
                wrap.append(el);
                index++;
            });

			//if the parent div wrapper is set to display:none fade in the parent
			if (wrap.parent().css('display') == "none") {
				wrap.show();
                // shop the parent div
				wrap.parent('div').fadeIn(opts.fadeTime);
			} else {
				wrap.fadeIn(opts.fadeTime);
			}
		}

		function showBitrateList() {
			if (self.getClip().bitrates.length > 0) {
                wrap = $(wrap);
                wrap.empty();
				buildBitrateList();
			}
		}

        self.onStart(function(clip) {
            showBitrateList();
            setActiveOption($('[index = "'+ clip.bitrate + '"]', $(wrap)));
		});

        return self;
	});

})(jQuery);