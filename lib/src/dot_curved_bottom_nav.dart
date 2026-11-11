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

  /// The radius of the dot.
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
  })  : assert(items.isNotEmpty),
        assert(0 <= selectedIndex && selectedIndex < items.length),
        assert(0 <= height && height <= 75.0),
        assert(hideOnScroll ? scrollController != null : true,
            "You need to provide [scrollController] parameter to enable hide on scroll"),
        assert(borderRadius >= 0 && borderRadius <= 30),
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
      _sliderController.duration = widget.animationDuration;
    }

    // The scroll listener ignores scrolling once hiding is turned off, so
    // bring the bar back here or it stays hidden.
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
                // Same side inset as the painter, so each icon stays centered
                // under its notch.
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.height * 0.4,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final inset = NavGeometry(
                        itemCount: widget.items.length,
                        height: widget.height,
                        borderRadius: widget.borderRadius,
                        indicatorSize: widget.indicatorSize,
                      ).sideInset(constraints.maxWidth);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: inset),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < widget.items.length; i++)
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => _buttonTap(i),
                                  child: widget.items[i],
                                ),
                              ),
                          ],
                        ),
                      );
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

  void _scrollListener() {
    final controller = widget.scrollController;
    if (!widget.hideOnScroll || controller == null || !controller.hasClients) {
      return;
    }

    // A controller can drive several scroll views at once, so look at all of
    // them rather than `controller.position`, which throws in that case.
    for (final position in controller.positions) {
      switch (position.userScrollDirection) {
        case ScrollDirection.reverse:
          _hide();
          return;
        case ScrollDirection.forward:
          _show();
          return;
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

  void _buttonTap(int index) {
    widget.onTap?.call(index);
    _moveTo(index);
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
