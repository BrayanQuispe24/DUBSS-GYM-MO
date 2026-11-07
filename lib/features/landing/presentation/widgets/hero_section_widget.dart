import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navyBlueDark,
            AppColors.navyBlue,
            AppColors.primaryRedDark,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DUBS Institutional Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: AppColors.accentGold, size: 14),
                SizedBox(width: 6),
                Text(
                  'BIENESTAR SOCIAL (D.U.B.S.)',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Hero Title
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.25,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: 'Gimnasio Universitario '),
                TextSpan(
                  text: 'UAGRM\n',
                  style: TextStyle(color: AppColors.accentGold),
                ),
                TextSpan(
                  text: 'Salud, Deporte & Rendimiento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Description paragraph
          const Text(
            'Espacio deportivo universitario diseñado exclusivamente para Estudiantes, Administrativos y Docentes de la UAGRM.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Hero Image Card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/images/gym_auth_banner.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onExploreTap,
                  icon: const Icon(Icons.explore, size: 16),
                  label: const Text('Disciplinas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMembershipsTap,
                  icon: const Icon(Icons.badge, size: 16),
                  label: const Text('Membresías'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
