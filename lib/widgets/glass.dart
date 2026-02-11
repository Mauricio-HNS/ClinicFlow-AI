import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    this.opacity = 0.12,
    this.tint,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final baseTint = tint ?? AppColors.surface;
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.85),
                  blurRadius: 16,
                  offset: const Offset(-5, -5),
                ),
                BoxShadow(
                  color: const Color(0xFF8FB5E6).withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(9, 11),
                ),
              ],
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: baseTint.withValues(alpha: (opacity + 0.42).clamp(0.0, 0.95)),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
