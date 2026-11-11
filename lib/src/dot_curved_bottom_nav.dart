import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'curved_nav_painter.dart';

/// A beautiful and animated bottom navigation that may or may not be curved
/// and has a beautiful indicator around which the bottom nav is curved.
///
/// Update [selectedIndex] to change the selected item.
/// [selectedIndex] is required and must not be null.
class DotCurvedBottomNav extends StatefulWidget {
  /// Animation curve of hiding animation and dot indicator moving between
  /// indices.
  final Curve animationCurve;

  /// Animation Duration of hiding animation and dot indicator moving between
  /// indices.
  final Duration animationDuration;

  /// Background color of the bottom navigation
  final Color backgroundColor;

  /// Color fo the dot indicator shown on the currently selected item
  final Color indicatorColor;

  /// Configures height of bottom navigation. The limitations of [height] are
  /// enforced through assertions.
  final double height;

  /// Configures the size of indicator
  final double indicatorSize;

  /// Configures currently selected / highlighted index
  final int selectedIndex;

  /// Defines the appearance of the buttons that are displayed in the bottom
  /// navigation bar. This should have at least two items and five at most.
  final List<Widget> items;

  /// Callback function that is invoked whenever an Item is tapped on by the user
  final ValueChanged<int>? onTap;

  /// [scrollController] is used to listen to when the user is scrolling the page
  /// and hided the bottom navigation
  final ScrollController? scrollController;

  /// Used to configure the borderRadius of the [DotCurvedBottomNav]. Defaults to 25.
  final double borderRadius;
  final EdgeInsets margin;

  /// Used to configure the margin around [DotCurvedBottomNav]. Increase it to make
  /// [DotCurvedBottomNav] float.
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

  /// The index the dot is at or is moving to.
  late int _targetIndex;

  late double _pos;

  @override
  void initState() {
    super.initState();
    // Set these here rather than lazily: read for the first time inside
    // didUpdateWidget, they would pick up the new widget's index.
    _targetIndex = widget.selectedIndex;
    _pos = widget.selectedIndex.toDouble();
    _animationController
        .addListener(() => setState(() => _pos = _animationController.value));
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
    if (!widget.hideOnScroll && _sliderController.value > 0) {
      _sliderController.reverse();
    }

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
    return AnimatedBuilder(
      animation: _sliderController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0,
              (widget.height + widget.margin.bottom) * _sliderController.value),
          child: Container(
            height: widget.height,
            margin: widget.margin,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CurvedNavPainter(
                      startingLoc: _pos,
                      itemsLength: widget.items.length,
                      color: widget.backgroundColor,
                      indicatorColor: widget.indicatorColor,
                      textDirection: Directionality.of(context),
                      indicatorSize: widget.indicatorSize,
                      borderRadius: widget.borderRadius,
                    ),
                    child: Container(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: widget.height * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                ),
                // Row(),
              ],
            ),
          ),
        );
      },
    );
  }

  _scrollListener() {
    if (_sliderController.isAnimating || widget.hideOnScroll == false) {
      return;
    }

    if (widget.scrollController?.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_sliderController.isCompleted) {
        _sliderController.reverse();
      }
    } else if (widget.scrollController?.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if ((_sliderController.isCompleted || !_sliderController.isAnimating)) {
        _sliderController.forward();
      }
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
