import 'package:flutter/material.dart';

/// Animation curves the Style tab lets you try on the indicator.
enum NavCurve {
  ease('Ease', Curves.ease),
  easeOutBack('Overshoot', Curves.easeOutBack),
  elasticOut('Elastic', Curves.elasticOut),
  bounceOut('Bounce', Curves.bounceOut),
  linear('Linear', Curves.linear);

  const NavCurve(this.label, this.curve);

  final String label;
  final Curve curve;
}

/// Every [DotCurvedBottomNav] option the example exposes, in one place.
@immutable
class NavStyle {
  const NavStyle({
    this.backgroundColor = const Color(0xff1E2A4A),
    this.indicatorColor = const Color(0xffFFC145),
    this.indicatorSize = 5,
    this.borderRadius = 25,
    this.height = 70,
    this.horizontalMargin = 16,
    this.durationMs = 300,
    this.curve = NavCurve.ease,
    this.itemCount = 4,
    this.hideOnScroll = true,
  });

  final Color backgroundColor;
  final Color indicatorColor;
  final double indicatorSize;
  final double borderRadius;
  final double height;
  final double horizontalMargin;
  final int durationMs;
  final NavCurve curve;
  final int itemCount;
  final bool hideOnScroll;

  /// Color for icons that are not selected, readable on [backgroundColor].
  Color get idleIconColor =>
      ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
          ? Colors.white70
          : Colors.black54;

  NavStyle copyWith({
    Color? backgroundColor,
    Color? indicatorColor,
    double? indicatorSize,
    double? borderRadius,
    double? height,
    double? horizontalMargin,
    int? durationMs,
    NavCurve? curve,
    int? itemCount,
    bool? hideOnScroll,
  }) {
    return NavStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      borderRadius: borderRadius ?? this.borderRadius,
      height: height ?? this.height,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      durationMs: durationMs ?? this.durationMs,
      curve: curve ?? this.curve,
      itemCount: itemCount ?? this.itemCount,
      hideOnScroll: hideOnScroll ?? this.hideOnScroll,
    );
  }
}
