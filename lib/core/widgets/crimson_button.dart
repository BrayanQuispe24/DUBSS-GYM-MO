import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CrimsonButtonStyle {
  solid,
  gradient,
  glassPill,
  outline,
}

/// Botón CTA deportivo oficial "UAGRM Crimson"
/// Soporta estilos: solid (#990000), gradient (#990000 -> #DC2626),
/// glassPill (translúcido con micro-borde) y outline.
class CrimsonButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String label;
  final CrimsonButtonStyle style;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double height;
  final double borderRadius;

  const CrimsonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.style = CrimsonButtonStyle.solid,
    this.isLoading = false,
    this.padding,
    this.width,
    this.height = 42,
    this.borderRadius = 4.0,
  });

  /// Constructor de fábrica para botón estilo píldora deportiva con micro-borde
  factory CrimsonButton.pill({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Widget? icon,
    bool isLoading = false,
    double? width,
    double height = 38,
    EdgeInsetsGeometry? padding,
  }) {
    return CrimsonButton(
      key: key,
      onPressed: onPressed,
      label: label,
      icon: icon,
      style: CrimsonButtonStyle.glassPill,
      isLoading: isLoading,
      width: width,
      height: height,
      padding: padding,
      borderRadius: 999.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    Color textColor = AppColors.textWhite;

    switch (style) {
      case CrimsonButtonStyle.solid:
        decoration = BoxDecoration(
          color: onPressed != null ? AppColors.primaryCrimson : AppColors.carbonSurfaceMuted,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: onPressed != null ? AppColors.accentHover : AppColors.borderSubtle,
            width: 1.0,
          ),
        );
        break;

      case CrimsonButtonStyle.gradient:
        decoration = BoxDecoration(
          gradient: onPressed != null ? AppColors.crimsonGradient : null,
          color: onPressed == null ? AppColors.carbonSurfaceMuted : null,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: onPressed != null ? AppColors.accentVibrant : AppColors.borderSubtle,
            width: 1.0,
          ),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.accentVibrant.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        );
        break;

      case CrimsonButtonStyle.glassPill:
        decoration = BoxDecoration(
          color: const Color(0xB30F0F14), // rgba(15, 15, 20, 0.7)
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.borderTranslucent,
            width: 1.0,
          ),
        );
        break;

      case CrimsonButtonStyle.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        );
        textColor = AppColors.textSlateLight;
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        else if (icon != null) ...[
          icon!,
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );

    return Container(
      width: width,
      constraints: BoxConstraints(
        minHeight: height,
      ),
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: style == CrimsonButtonStyle.glassPill
              ? AppColors.primaryCrimson.withValues(alpha: 0.2)
              : AppColors.accentHover.withValues(alpha: 0.2),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Center(
              widthFactor: width != null ? null : 1.0,
              heightFactor: 1.0,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
