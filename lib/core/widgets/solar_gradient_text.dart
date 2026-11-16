import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renderiza texto con el degradado deportivo Solar (#FFD700 a #FF9500)
class SolarGradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const SolarGradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))
        .copyWith(color: Colors.white);

    return ShaderMask(
      shaderCallback: (bounds) => AppColors.solarGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: effectiveStyle,
      ),
    );
  }
}

