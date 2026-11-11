## 0.0.1

* Stunning Animating Curved Shape Around Indicator Navigation Bar. Adjustable color, background color, animation curve, animation duration.
* Hopefully will be adding more indicator shapes in the future release. Do open an issue on github if you face any.

## 0.0.1+2
* Specified platforms

## 0.0.2
* Updated doc images and readme

## Unreleased
* Fixed animation controllers never being disposed, which leaked and raised errors when the bar was removed mid-animation.
* `onTap` is no longer called again when the app changes `selectedIndex`, so one tap reports one index.
* The dot now starts on the selected item and follows changes to the number of items and to `animationDuration`.
* Right-to-left layouts now put the dot under the correct item.
* The bar stays above the bottom safe area. The bottom margin is now at least the safe area inset.
* Hide on scroll works with a controller shared by several scroll views, follows quick changes of direction, and brings the bar back when it is turned off.
* Moving the dot now repaints only the bar's background instead of rebuilding the whole bar on every frame.
* Fixed a spike at the corner when the dot is on the first or last item. The notch is now centered on the dot and keeps the same shape everywhere. With many items, the first and last are moved in slightly so their notch clears the rounded corners.
* Icons are now centered in the space below the notch, and each item's tap area covers the bar's full height. The space at either end of the bar taps the nearest item.
* A new `animationDuration` now also applies to a move or hide already under way.
* `indicatorSize` must be positive and small enough for the dot to fit its notch (its diameter plus 4 must fit in half the bar's height). Larger values are rejected in debug builds.
* Every item is at least 40 wide. When the bar is too narrow for full corners as well, all four corners shrink evenly. A bar too narrow for its items reports how wide it needs to be in debug builds.
* Items shrink slightly while pressed and spring back with a small bounce when released. Set the new `pressedScale` to 1 to turn this off.
