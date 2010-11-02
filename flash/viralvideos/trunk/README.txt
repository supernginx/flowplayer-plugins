Version history:

3.2.4
-----
- Removed line breaks from the embed code
- Embed code: The plugin URLs are not touched if they are complete URLs

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
