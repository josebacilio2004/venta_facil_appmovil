import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FintechCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final Border? border;
  final VoidCallback? onTap;

  const FintechCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.color,
    this.border,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);
    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceCardColor,
        borderRadius: effectiveRadius,
        border: border ?? Border.all(color: AppTheme.outlineVariantColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003FA4).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
