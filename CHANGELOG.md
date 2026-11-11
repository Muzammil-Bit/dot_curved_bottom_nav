## 0.1.0

### Behavior changes
* `onTap` is no longer called when the app changes `selectedIndex` itself, so one tap reports one index.
* The bar stays above the bottom safe area. The bottom margin is now at least the safe area inset.
* The notch is centered on the dot and keeps the same shape everywhere. With many items, the first and last are moved in slightly so their notch clears the rounded corners.
* Icons are centered in the space below the notch, a few pixels lower than before.
* `indicatorSize` must be positive and small enough for the dot to fit its notch: its diameter plus 4 must fit in half the bar's height. Larger values are rejected in debug builds.
* Every item is at least 40 wide. A bar too narrow for its items reports how wide it needs to be in debug builds. When a bar is too narrow for full corners, all four corners shrink evenly.
* Requires Flutter 3.16 or later.

### New
* Items shrink slightly while pressed and spring back with a small bounce when released. Set `pressedScale` to 1 to turn this off.
* Each item's tap area covers the bar's full height, and the space at either end of the bar taps the nearest item.

### Fixes
* Animation controllers are now disposed, which stops a leak and the errors raised when the bar was removed mid-animation.
* The dot starts on the selected item and follows changes to the number of items and to `animationDuration`, without a new `Key`.
* A new `animationDuration` also applies to a move or hide already under way.
* Right-to-left layouts put the dot under the correct item.
* Fixed a spike at the corner when the dot was on the first or last item.
* Hide on scroll works with a controller shared by several scroll views, follows quick changes of direction, prefers the list being dragged over one still coasting, and brings the bar back when it is turned off.

### Performance
* Moving the dot only repaints the bar's background. Nothing is rebuilt or laid out again on each frame.

## 0.0.2
* Updated doc images and readme

## 0.0.1+2
* Specified platforms

## 0.0.1
* Stunning Animating Curved Shape Around Indicator Navigation Bar. Adjustable color, background color, animation curve, animation duration.
* Hopefully will be adding more indicator shapes in the future release. Do open an issue on github if you face any.
