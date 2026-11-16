import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum StatusBadgeVariant {
  success,
  crimson,
  solar,
  neutral,
}

/// Badge técnico estilo SaaS deportivo con micro-bordes y colores oficiales
class StatusBadge extends StatelessWidget {
  final String label;
  final Widget? icon;
  final StatusBadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = StatusBadgeVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    switch (variant) {
      case StatusBadgeVariant.success:
        bg = AppColors.successEmerald.withValues(alpha: 0.12);
        border = AppColors.successEmerald.withValues(alpha: 0.3);
        textColor = AppColors.successLight;
        break;

      case StatusBadgeVariant.crimson:
        bg = AppColors.primaryCrimson.withValues(alpha: 0.15);
        border = AppColors.accentVibrant.withValues(alpha: 0.35);
        textColor = AppColors.accentVibrant;
        break;

      case StatusBadgeVariant.solar:
        bg = AppColors.solarAmber.withValues(alpha: 0.12);
        border = AppColors.solarGold.withValues(alpha: 0.35);
        textColor = AppColors.solarGold;
        break;

      case StatusBadgeVariant.neutral:
        bg = AppColors.carbonSurfaceMuted;
        border = AppColors.borderSubtle;
        textColor = AppColors.textSlateLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

