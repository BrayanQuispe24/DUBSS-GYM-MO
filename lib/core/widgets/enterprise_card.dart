import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tarjeta estilo "Boxed-Sharpness" Enterprise SaaS
/// Color Carbon (#141419), micro-borde de 1px (#272732) y esquinas nítidas (4px).
class EnterpriseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isFeatured;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const EnterpriseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.isFeatured = false,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ??
        (isFeatured ? AppColors.accentVibrant : AppColors.borderSubtle);
    final effectiveBgColor = backgroundColor ?? AppColors.carbonSurface;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: isFeatured ? 1.5 : 1.0,
        ),
        boxShadow: isFeatured
            ? [
                BoxShadow(
                  color: AppColors.accentVibrant.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: AppColors.surfaceHover,
          splashColor: AppColors.accentVibrant.withValues(alpha: 0.1),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

