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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyBlueDark,
            AppColors.navyBlueDark.withValues(alpha: 0.95),
            AppColors.primaryRedDark.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Imagen de fondo con opacidad
          Positioned.fill(
            child: Opacity(
              opacity: 0.22,
              child: Image.asset(
                'assets/images/gym_auth_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),

          // Contenido del Banner
          Padding(
            padding: EdgeInsets.fromLTRB(20, compact ? 16 : 24, 20, compact ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado Marca
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(8),
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
                          'FITGO UAGRM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'D.U.B.S. UNIVERSITARIO',
                          style: TextStyle(
                            color: AppColors.accentGold,
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

                // Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'GIMNASIO UNIVERSITARIO UAGRM',
                    style: TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Título
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: 'Transforma tu '),
                      TextSpan(
                        text: 'potencial ',
                        style: TextStyle(color: Color(0xFFFF5252)),
                      ),
                      TextSpan(text: 'físico'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                const Text(
                  'Forma parte de la comunidad deportiva de la UAGRM. Accede a nuestras salas de musculación y entrenamiento profesional.',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),

                if (!compact) ...[
                  const SizedBox(height: 14),
                  _buildBullet(Icons.fitness_center, 'Maquinaria y musculación de primera clase'),
                  const SizedBox(height: 6),
                  _buildBullet(Icons.bolt, 'Descuentos exclusivos para la comunidad UAGRM'),
                  const SizedBox(height: 6),
                  _buildBullet(Icons.verified_user, 'Registro seguro con notificación oficial'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accentGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
