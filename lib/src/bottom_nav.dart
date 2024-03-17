import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'custom_nav_painter.dart';

class CustomBottomNav extends StatefulWidget {
  final Curve animationCurve;
  final Duration animationDuration;
  final Color backgroundColor;
  final Color indicatorColor;
  final double height;
  final double indicatorSize;
  final int index;
  final List<Widget> items;
  final ValueChanged<int>? onTap;
  final ScrollController? scrollController;
  final double borderRadius;
  final EdgeInsets margin;
  final bool hideOnScroll;

  CustomBottomNav({
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
    this.index = 0,
    this.onTap,
    this.borderRadius = 25,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  })  : assert(items.isNotEmpty),
        assert(0 <= index && index < items.length),
        assert(0 <= height && height <= 75.0),
        assert(hideOnScroll ? scrollController != null : true,
            "You need to provide [scrollController] parameter to enable hide on scroll"),
        assert(borderRadius >= 0 && borderRadius <= 30),
        super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late double _pos;

  late final AnimationController _sliderController = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
    reverseDuration: widget.animationDuration,
  );

  @override
  void dispose() {
    super.dispose();
    widget.scrollController?.removeListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant CustomBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _buttonTap(widget.index);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    _pos = widget.index / widget.items.length;
    _animationController = AnimationController(
      vsync: this,
      value: _pos,
      lowerBound: 0,
      upperBound: widget.items.length.toDouble(),
    );
    _animationController
        .addListener(() => setState(() => _pos = _animationController.value));

    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sliderController,
      builder: (context, child) {
        log("VALI E:: ${_sliderController.value}");
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
                    painter: NavCustomPainter(
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
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    _animationController.animateTo(index.toDouble(),
        duration: widget.animationDuration, curve: widget.animationCurve);
  }
}
