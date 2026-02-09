import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final double blur;
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
    this.blur = 18,
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
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: baseTint.withValues(alpha: opacity),
              borderRadius: borderRadius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 18,
                      offset: const Offset(-6, -6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(8, 10),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
