import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final double opacity;
  final Color? tint;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.opacity = 0.18,
    this.tint,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final baseTint = tint ?? Colors.white;
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: baseTint.withValues(alpha: opacity),
          borderRadius: borderRadius,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(6, 6),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(-4, -4),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}
