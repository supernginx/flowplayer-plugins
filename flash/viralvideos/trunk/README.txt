Version history:

3.2.8
-----
- The 'shareUrl' configuration option was removed and replaced by clip.pageUrl.
- updated Twitter sharing URL according to their new sharing API
Fixes:
- embed code now just uses the OBJECT tag, issue #301
- added new configuration option 'gap' to the dock. Defines the gap between buttons. Default is 5.
- the embed code now includes "wmode" with value "transparent". Issue #306
- refactoring of configs, reconformed all window label text to labels config, changed share description configs to title config. #290
- #410 toggle out of fullscreen due to flash user input restrictions.

3.2.5
-----

Fixes:
- fixed error when share.facebook: false, http://code.google.com/p/flowplayer-core/issues/detail?id=207
- the dock button were clickable even when they were hidden: http://code.google.com/p/flowplayer-core/issues/list?cursor=206
- disabling email/embed/share did not remove the dock button: http://code.google.com/p/flowplayer-core/issues/detail?id=205

3.2.4
-----
- removed config property "popupOnClip", introduced "shareWindow" with values "_self", "_blank", "_parent", "_top", "_popup".
  the default is "_popup"
- sharing popup dimensions are now specified as [width, height] instead of [height, width]
- Removed line breaks from the embed code
- Embed code: The plugin URLs are not touched if they are complete URLs
- Added new configuration option "dock": http://code.google.com/p/flowplayer-core/issues/detail?id=151
Fixes:
- Embed code did not work correctly with RSS or SMIL playlists

3.2.3
-----
- Added support for HTML5 fallback in the supplied embed code, thanks Claus Pedersen. http://flowplayer.org/forum/5/48905
Fixes:
- The videoLink was not passed on to the email template. http://flowplayer.org/forum/5/48840
- The stumbleupon config variable was misspelled
- the email/share/embed buttons were sized incorrectly after fullscreen: http://flowplayer.org/forum/5/49309

3.2.2
-----
- Added 'shareUrl' config option that can be used to override the URL to be used when sharing to social sites
- Added 'configUrl' parameter to specify and external config file to load
- Added prerollUrl, postrollUrl, autoPlay, autoBuffering and linkUrl params to the embed config
- Added possibility to specify display properties for the icons (share, embed, email buttons)
Fixes:
- Now the embed functionality works properly when the contols plugin is built into the player. Was causing an error
  when the the user selected colors for the controlbar background and buttons.
- fixed issue #130: Viral videos icons shrink down in fullscreen

3.2.1
-----

Fixes :
 - Error when disabling a tab
 - Wrong plugin urls in embed code


3.2.0
-----
- the first release
