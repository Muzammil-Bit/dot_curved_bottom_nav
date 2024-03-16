import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'custom_nav_painter.dart';

class CustomBottomNav extends StatefulWidget {
  final Curve animationCurve;
  final Duration animationDuration;
  final Color backgroundColor;
  final Color? buttonBackgroundColor;
  final Color color;
  final double height;
  final int index;
  final List<Widget> items;
  final ValueChanged<int>? onTap;
  final ScrollController scrollController;

  CustomBottomNav({
    Key? key,
    required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.onTap,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 75.0,
    required this.scrollController,
  })  : assert(items.isNotEmpty),
        assert(0 <= index && index < items.length),
        assert(0 <= height && height <= 75.0),
        super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late double _pos;
  late final Animation<Offset> _sliderAnimation =
      Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 120))
          .chain(CurveTween(curve: Curves.fastOutSlowIn))
          .animate(_sliderController);

  late final AnimationController _sliderController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
    reverseDuration: const Duration(milliseconds: 600),
  );

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(_scrollListener);
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
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
      });
    });

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sliderController,
      builder: (context, child) {
        return Transform.translate(
          offset: _sliderAnimation.value,
          child: Container(
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: NavCustomPainter(
                      _pos,
                      widget.items.length,
                      Colors.red,
                      Directionality.of(context),
                    ),
                    child: Container(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < widget.items.length; i++)
                        Expanded(
                          child: GestureDetector(
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
    if (_sliderController.isAnimating) {
      return;
    }
    if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_sliderController.isCompleted) {
        _sliderController.reverse();
      }
    } else if (widget.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if ((_sliderController.isCompleted || !_sliderController.isAnimating)) {
        _sliderController.forward();
      }
    }
    return;
  }

  void _buttonTap(int index) {
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    setState(() {
      _animationController.animateTo(index.toDouble(),
          duration: widget.animationDuration, curve: widget.animationCurve);
    });
  }
}
