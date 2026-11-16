import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';

class HeroSectionWidget extends StatelessWidget {
  final VoidCallback? onExploreTap;
  final VoidCallback? onMembershipsTap;
  final VoidCallback? onLoginTap;

  const HeroSectionWidget({
    super.key,
    this.onExploreTap,
    this.onMembershipsTap,
    this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.obsidianBase,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: Stack(
        children: [
          // Textura ambiental tenue de fondo (10% de opacidad, cero interferencia visual)
          Positioned.fill(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'assets/images/gym_auth_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Resplandor carmesí muy suave en esquina superior derecha
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x28990000), // Resplandor muy tenue
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),

          // Contenido limpio y aireado
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag discreto
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.accentVibrant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'INFRAESTRUCTURA DEPORTIVA',
                        style: TextStyle(
                          color: AppColors.solarGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Título motivacional de alto impacto (cero repetición)
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textWhite,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                    children: [
                      TextSpan(text: 'Transforma tu\n'),
                      TextSpan(
                        text: 'Potencial Físico',
                        style: TextStyle(
                          color: AppColors.solarGold,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Una sola línea descriptiva clara
                const Text(
                  'Instalaciones de primer nivel y acondicionamiento profesional con aranceles subvencionados.',
                  style: TextStyle(
                    color: AppColors.textSlateLight,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Acciones claras y sin amontonamiento
                Row(
                  children: [
                    CrimsonButton(
                      onPressed: onMembershipsTap,
                      icon: const Icon(Icons.card_membership_rounded, size: 15, color: Colors.white),
                      label: 'Ver Membresías',
                      style: CrimsonButtonStyle.gradient,
                      height: 40,
                    ),
                    const SizedBox(width: 14),
                    TextButton.icon(
                      onPressed: onExploreTap,
                      icon: const Icon(Icons.arrow_downward_rounded, size: 15, color: AppColors.textSlateMuted),
                      label: const Text(
                        'Disciplinas',
                        style: TextStyle(
                          color: AppColors.textSlateLight,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
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
