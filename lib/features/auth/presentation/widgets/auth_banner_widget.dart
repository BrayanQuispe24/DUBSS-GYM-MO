import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthBannerWidget extends StatelessWidget {
  final bool compact;

  const AuthBannerWidget({
    super.key,
    this.compact = false,
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
          // Imagen de fondo con opacidad suave
          Positioned.fill(
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/gym_auth_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),

          // Resplandor radial carmesí en la esquina
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x40990000), // rgba(153, 0, 0, 0.25)
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
          ),

          // Contenido del Banner
          Padding(
            padding: EdgeInsets.fromLTRB(20, compact ? 16 : 24, 20, compact ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado Marca Oficial UAGRM
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GIMNASIO UAGRM',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'D.U.B.S. UNIVERSITARIO',
                          style: TextStyle(
                            color: AppColors.solarGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pill Badge Boxed-Sharpness
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xB30F0F14), // rgba(15, 15, 20, 0.7)
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderTranslucent, width: 1.0),
                  ),
                  child: const Text(
                    'BIENESTAR SOCIAL · GIMNASIO UNIVERSITARIO',
                    style: TextStyle(
                      color: AppColors.solarGold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Título con Acento Vibrante
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textWhite,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: 'Transforma tu '),
                      TextSpan(
                        text: 'potencial ',
                        style: TextStyle(color: AppColors.accentVibrant),
                      ),
                      TextSpan(text: 'físico'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                const Text(
                  'Forma parte de la comunidad deportiva de la UAGRM. Accede a nuestras salas de musculación y entrenamiento profesional.',
                  style: TextStyle(
                    color: AppColors.textSlateLight,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                if (!compact) ...[
                  const SizedBox(height: 14),
                  _buildBullet(Icons.fitness_center, 'Maquinaria y musculación de primera clase', AppColors.solarGold),
                  const SizedBox(height: 6),
                  _buildBullet(Icons.bolt, 'Descuentos exclusivos para la comunidad UAGRM', AppColors.accentVibrant),
                  const SizedBox(height: 6),
                  _buildBullet(Icons.verified_user, 'Registro seguro con notificación oficial', AppColors.successEmerald),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSlateLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
