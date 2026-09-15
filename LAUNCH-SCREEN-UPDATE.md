# Website-matched launch experience

The iOS app now uses the same finished transparent Mosquito Ninja artwork and
the same theatrical motion language as the public website splash:

- oversized throwing-star mosquito mark;
- dark, background-free artwork with a red aura, expanding burst and orbit;
- a short red strike aligned directly over the prohibition bar in the mark;
- the supplied `MOSQUITO NINJA / BITE BACK!` transparent wordmark;
- staged scale, rotation, strike, center-reveal and fade timing;
- a short haptic accent on the strike; and
- a static, abbreviated presentation when Reduce Motion is enabled.

The system launch storyboard uses the same transparent mark at 270 by 270
points, 80% larger than the previous 150-point mark, so the handoff to the
animated UIKit overlay feels intentional. The runtime mark scales up to 88% of
the device width with compact-height and iPad limits.

The slash is positioned in mark-local coordinates at the same 46.6% vertical
center and -38-degree angle used by the website. It no longer spans the screen
or floats behind the logo.

No automatic CodeMagic trigger was added. Pushing this source update does not
consume an App Store Connect upload; use the build-only or App Store workflow
manually when ready.
