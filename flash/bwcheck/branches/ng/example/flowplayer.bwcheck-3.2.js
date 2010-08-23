/**
 * flowplayer.bwcheck
 */
(function($) {

	$f.addPlugin("bwcheck", function(container, options) {

		// self points to current Player instance
		var self = this;

		var opts = {
			selectedBitrateClass: 'bitrate-selected',
			activeClass: 'bitrate-active',
			bitrateInfoClass:'bitrate-info',
			disabledClass: 'bitrate-disabled',
			bwCheckPlugin: 'bwcheck',
			template: '<a href="{bitrate}">{label}</a>',
			disabledText: '(not valid with this player size )',
			fadeTime: 500,
			seperator: ""
		};

		$.extend(opts, options);

		var wrap = container;
		var template = null;
		var labels = null;
		var plugin = self.getPlugin(opts.bwCheckPlugin) || null;
		var els = null;

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

		function buildBitrateList() {
			wrap.fadeOut(opts.fadeTime).empty();


			labels = plugin.labels;
	
			var widthCheck = (plugin.getSelectionStrategy() == "default");
			var containerWidth = $("#" + self.id()).width();


			var index = 0;
			var clip = self.getClip();
			$.each(clip.bitrates, function() {
				var el = parseTemplate(this);
				el = $(el);
				el.attr("index",this.bitrate);



				if (this.width > containerWidth && widthCheck) {
					

					if (el.is('a')) {
						el.removeAttr("href");
						el.addClass(opts.disabledClass);
					}

					if (el.is('input')) {
						el.attr("disabled");
						el.addClass(opts.disabledClass);
					}
					//el.find('a').removeAttr("href").addClass(opts.disabledClass);
					//el.find('input').attr("disabled",true).addClass(opts.disabledClass);

					wrap.append(el);
					wrap.append(" " + opts.disabledText + " ");
				} else {
					el.addClass(opts.activeClass);
					el.click(function() {
						el.removeClass(opts.activeClass);

						wrap.children(":not([class="+opts.disabledClass+"])").removeClass(opts.selectedBitrateClass).addClass(opts.activeClass);
						el.addClass(opts.selectedBitrateClass);
						play($(this).attr("index"));
						if ($(this).is('a')) return false;
					});
					wrap.append(el);
				}

				if (index < self.getClip().bitrates.length - 1) wrap.append(opts.seperator);
				index++;
			});

			//if the parent div wrapper is set to display:none fade in the parent
			if (wrap.parent().css('display') == "none") {
				wrap.show();
				wrap.parent('div').fadeIn(opts.fadeTime);
			} else {
				wrap.fadeIn(opts.fadeTime);
			}
		}

		function play(bitrate)  {
			if (!plugin) return false;

			plugin.setBitrate(bitrate);

			return false;
		}

		function clearCSS() {
			els.removeClass(opts.bitrateClass);
			els.removeClass(opts.selectedBitrateClass);
			els.removeClass(opts.bitrateInfoClass);
		}

		function showBitrateList() {

			wrap = $(wrap);
			if (self.getClip().bitrates.length > 0) {
				if (!template) template = wrap.is(":empty") ? opts.template : wrap.html();
				wrap.empty();


				buildBitrateList();

			}
		}

	
		
		self.onStart(function(clip) {
			 showBitrateList();
		});
		
		/*self.getPlugin("bwcheck").onStreamSwitch(function(mappedBitrate, streamName, oldStreamName) {

		});*/

		return self;

	});

})(jQuery);
