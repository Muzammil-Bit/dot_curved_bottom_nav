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
* Fixed a spike at the corner when the dot is on the first or last item. The notch is now centered on the dot, and next to a corner it narrows on that side so the corner keeps its radius.
