import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double radius;
  final double glowBlur;
  final EdgeInsetsGeometry padding;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
    this.radius = 6,
    this.glowBlur = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = AppColors.buttonRadius;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.neumorphicBase,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            ),
            child: Icon(icon, color: AppColors.primaryEnd, size: 18),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryEnd,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neumorphicBase,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.78),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neumorphicLightShadow,
            blurRadius: 11,
            offset: const Offset(-5, -5),
          ),
          BoxShadow(
            color: AppColors.neumorphicDarkShadow,
            blurRadius: glowBlur + 2,
            spreadRadius: 0.6,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(effectiveRadius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
