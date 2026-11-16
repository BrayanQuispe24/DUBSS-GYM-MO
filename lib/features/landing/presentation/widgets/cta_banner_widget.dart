import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';

class CtaBannerWidget extends StatelessWidget {
  final VoidCallback? onRegisterTap;
  final VoidCallback? onRequirementsTap;

  const CtaBannerWidget({
    super.key,
    this.onRegisterTap,
    this.onRequirementsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Stack(
        children: [
          // Radial glow sutil de fondo
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x33990000), // rgba(153, 0, 0, 0.2)
                    Colors.transparent,
                  ],
                  radius: 0.8,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Únete al Gimnasio Universitario UAGRM',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consulta los requisitos en Bienestar Social (D.U.B.S.) e inicia hoy tu entrenamiento físico.',
                  style: TextStyle(
                    color: AppColors.textSlateLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CrimsonButton(
                        onPressed: onRegisterTap,
                        label: 'Preinscribirme',
                        style: CrimsonButtonStyle.gradient,
                        height: 44,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CrimsonButton(
                        onPressed: onRequirementsTap,
                        label: 'Ver Requisitos',
                        style: CrimsonButtonStyle.glassPill,
                        height: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
