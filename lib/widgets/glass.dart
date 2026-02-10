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
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: baseTint.withValues(alpha: opacity),
          borderRadius: borderRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
          ),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 16,
                  offset: const Offset(6, 6),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(-4, -4),
                ),
                BoxShadow(
                  color: AppColors.glow.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 0),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}
