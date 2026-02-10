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
    this.radius = 20,
    this.glowBlur = 34,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 8),
        ],
        Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryStart, AppColors.primaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withValues(alpha: 0.85),
            blurRadius: glowBlur,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primaryEnd.withValues(alpha: 0.45),
            blurRadius: glowBlur * 0.8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
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
