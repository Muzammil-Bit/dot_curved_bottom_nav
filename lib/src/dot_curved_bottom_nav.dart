import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'curved_nav_painter.dart';

/// A bottom navigation bar whose top edge curves around a dot that marks the
/// selected item.
///
/// The app owns the selection: pass the current index as [selectedIndex] and
/// update it from [onTap]. Changing [selectedIndex] in code also moves the dot.
class DotCurvedBottomNav extends StatefulWidget {
  /// The curve the dot follows when it moves between items.
  final Curve animationCurve;

  /// How long the dot takes to move between items, and how long the bar takes
  /// to hide or show when [hideOnScroll] is on.
  final Duration animationDuration;

  /// The color of the bar.
  final Color backgroundColor;

  /// The color of the dot shown above the selected item.
  final Color indicatorColor;

  /// The height of the bar, not counting [margin]. At most 75.
  final double height;

  /// The radius of the dot. Its diameter plus 4 must fit in the top half of
  /// the bar, so at most 16.75 at the maximum [height] of 75.
  final double indicatorSize;

  /// The index of the selected item.
  final int selectedIndex;

  /// The widgets shown in the bar, usually icons. Use two to five.
  final List<Widget> items;

  /// Called with an item's index when the user taps it.
  final ValueChanged<int>? onTap;

  /// The controller of the page's scroll view. Needed when [hideOnScroll] is
  /// on. It may be attached to several scroll views at once.
  final ScrollController? scrollController;

  /// The corner radius of the bar, from 0 to 30. Defaults to 25.
  final double borderRadius;

  /// The space around the bar. Increase it to make the bar float.
  ///
  /// The bottom margin is never smaller than the device's bottom safe area,
  /// so the bar stays clear of the home indicator.
  final EdgeInsets margin;

  /// Whether the bar slides away while the user scrolls down and comes back
  /// when they scroll up. Requires [scrollController].
  final bool hideOnScroll;

  /// How small an item shrinks while it is pressed, as a fraction of its
  /// size. It springs back when released. Use 1 to turn the effect off.
  final double pressedScale;

  DotCurvedBottomNav({
    Key? key,
    required this.items,
    this.scrollController,
    this.hideOnScroll = false,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.backgroundColor = Colors.black,
    this.indicatorColor = Colors.white,
    this.height = 75.0,
    this.indicatorSize = 5,
    this.selectedIndex = 0,
    this.onTap,
    this.borderRadius = 25,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    this.pressedScale = 0.85,
  })  : assert(items.isNotEmpty),
        assert(0 <= selectedIndex && selectedIndex < items.length),
        assert(0 <= height && height <= 75.0),
        assert(hideOnScroll ? scrollController != null : true,
            "You need to provide [scrollController] parameter to enable hide on scroll"),
        assert(borderRadius >= 0 && borderRadius <= 30),
        assert(indicatorSize > 0, 'indicatorSize must be positive'),
        assert(pressedScale > 0 && pressedScale <= 1),
        assert(
          indicatorSize * 2 + 4 <= height / 2,
          'indicatorSize is too large for this height: the dot and the gap '
          'below it must fit in the top half of the bar',
        ),
        super(key: key);

  @override
  State<DotCurvedBottomNav> createState() => _DotCurvedBottomNavState();
}

class _DotCurvedBottomNavState extends State<DotCurvedBottomNav>
    with TickerProviderStateMixin {
  // Unbounded so it keeps working when the number of items changes, and so
  // overshooting curves can run past the first and last item.
  late final AnimationController _animationController =
      AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  late final AnimationController _sliderController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 1),
  ).animate(_sliderController);

  /// The index the dot is at or is moving to.
  late int _targetIndex;

  /// The item under a finger right now, shown slightly shrunk.
  int? _pressedIndex;

  /// The scroll direction last seen for each scroll view on the controller.
  /// Cleared whenever hiding is turned on or off, or the controller changes,
  /// so a direction from before doesn't hold back the next scroll.
  Expando<ScrollDirection> _lastDirections = Expando();

  @override
  void initState() {
    super.initState();
    // Set here rather than lazily: read for the first time inside
    // didUpdateWidget, it would pick up the new widget's index.
    _targetIndex = widget.selectedIndex;
    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant DotCurvedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_scrollListener);
      widget.scrollController?.addListener(_scrollListener);
    }

    if (oldWidget.animationDuration != widget.animationDuration) {
      _retime();
    }

    // The scroll listener ignores scrolling once hiding is turned off, so
    // bring the bar back here or it stays hidden.
    if (oldWidget.hideOnScroll != widget.hideOnScroll ||
        oldWidget.scrollController != widget.scrollController) {
      _lastDirections = Expando();
    }
    if (!widget.hideOnScroll) _show();

    // The app changed the selection itself. Move the dot, but don't report
    // it through onTap since the user didn't tap anything.
    _moveTo(widget.selectedIndex);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_scrollListener);
    _animationController.dispose();
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the bar clear of the home indicator and system navigation.
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final margin = widget.margin.copyWith(
      bottom: math.max(widget.margin.bottom, safeBottom),
    );

    // Hiding slides the bar down by its own height including margins, which
    // takes it fully off screen.
    return SlideTransition(
      position: _slideAnimation,
      child: RepaintBoundary(
        child: Padding(
          padding: margin,
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                // The dot repaints every frame while it moves. Its own layer
                // keeps the icons from repainting with it.
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: CurvedNavPainter(
                        position: _animationController,
                        itemsLength: widget.items.length,
                        color: widget.backgroundColor,
                        indicatorColor: widget.indicatorColor,
                        textDirection: Directionality.of(context),
                        indicatorSize: widget.indicatorSize,
                        borderRadius: widget.borderRadius,
                      ),
                    ),
                  ),
                ),
                // The icons fill the space below the notch. They share the
                // painter's geometry so each one stays centered under the dot.
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final geometry = NavGeometry(
                        width: constraints.maxWidth,
                        height: widget.height,
                        itemCount: widget.items.length,
                        borderRadius: widget.borderRadius,
                        indicatorSize: widget.indicatorSize,
                      );
                      assert(
                        geometry.fits,
                        'DotCurvedBottomNav is ${constraints.maxWidth} wide but '
                        'needs at least ${geometry.minWidth} for '
                        '${widget.items.length} items with an indicatorSize of '
                        '${widget.indicatorSize}. Reduce the margin, the number '
                        'of items or the indicatorSize.',
                      );
                      return _buildItems(geometry);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItems(NavGeometry geometry) {
    final inset = geometry.sideInset;
    final last = widget.items.length - 1;

    // Presses are tracked from the moment a finger touches the item. A tap
    // recognizer reports a quick tap's touch only when the finger lifts, which
    // would leave no time to show it.
    Widget item(int index, Widget child) => Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _setPressed(index),
          onPointerUp: (_) => _setPressed(null),
          onPointerCancel: (_) => _setPressed(null),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _buttonTap(index),
            child: child,
          ),
        );

    Widget icon(int index) {
      final pressed = _pressedIndex == index;
      return AnimatedScale(
        scale: pressed ? widget.pressedScale : 1,
        // Shrink quickly, then spring back with a slight bounce.
        duration: pressed
            ? const Duration(milliseconds: 90)
            : const Duration(milliseconds: 260),
        curve: pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.items[index],
      );
    }

    // Tap areas cover the bar's full height. Only the icons sit below the
    // notch.
    final iconPadding = EdgeInsets.only(top: geometry.notchDepth);
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i <= last; i++)
                Expanded(
                  child: item(
                    i,
                    Padding(
                      padding: iconPadding,
                      child: Center(child: icon(i)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // The space kept free at each end still belongs to the nearest item,
        // so a tap there isn't lost.
        if (inset > 0) ...[
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: inset,
            child: item(0, const SizedBox.expand()),
          ),
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            width: inset,
            child: item(last, const SizedBox.expand()),
          ),
        ],
      ],
    );
  }

  void _scrollListener() {
    final controller = widget.scrollController;
    if (!widget.hideOnScroll || controller == null) return;

    // A controller can drive several scroll views at once, and one can keep
    // coasting after a fling while the user drags another. React to the view
    // whose direction just changed rather than to whichever comes first, the
    // same way a UserScrollNotification would.
    for (final position in controller.positions) {
      final direction = position.userScrollDirection;
      if (_lastDirections[position] == direction) continue;
      _lastDirections[position] = direction;
      switch (direction) {
        case ScrollDirection.reverse:
          _hide();
        case ScrollDirection.forward:
          _show();
        case ScrollDirection.idle:
          break;
      }
    }
  }

  void _hide() {
    final status = _sliderController.status;
    if (status != AnimationStatus.forward &&
        status != AnimationStatus.completed) {
      _sliderController.forward();
    }
  }

  void _show() {
    final status = _sliderController.status;
    if (status != AnimationStatus.reverse &&
        status != AnimationStatus.dismissed) {
      _sliderController.reverse();
    }
  }

  void _setPressed(int? index) {
    if (_pressedIndex != index) setState(() => _pressedIndex = index);
  }

  void _buttonTap(int index) {
    widget.onTap?.call(index);
    _moveTo(index);
  }

  /// Applies a new [DotCurvedBottomNav.animationDuration] to animations that
  /// are already running, so the rest of the motion takes the new duration.
  void _retime() {
    final duration = widget.animationDuration;
    if (_animationController.isAnimating) {
      _animationController.animateTo(
        _targetIndex.toDouble(),
        duration: duration,
        curve: widget.animationCurve,
      );
    }

    _sliderController.duration = duration;
    // forward() and reverse() continue from the current value and scale the
    // new duration to the distance left.
    switch (_sliderController.status) {
      case AnimationStatus.forward:
        _sliderController.forward();
      case AnimationStatus.reverse:
        _sliderController.reverse();
      case AnimationStatus.completed:
      case AnimationStatus.dismissed:
        break;
    }
  }

  void _moveTo(int index) {
    if (index == _targetIndex) return;
    _targetIndex = index;
    _animationController.animateTo(
      index.toDouble(),
      duration: widget.animationDuration,
      curve: widget.animationCurve,
    );
  }
}
