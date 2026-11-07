import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HowItWorksWidget extends StatelessWidget {
  const HowItWorksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      {
        'step': '1',
        'icon': Icons.search,
        'title': 'Elige tu Actividad',
        'desc': 'Selecciona la disciplina que más se ajuste a tu horario y objetivos deportivos.',
      },
      {
        'step': '2',
        'icon': Icons.school,
        'title': 'Valida tu Perfil',
        'desc': 'Verifica tu registro universitario como estudiante regular, docente o administrativo.',
      },
      {
        'step': '3',
        'icon': Icons.qr_code,
        'title': 'Inscríbete y Entrena',
        'desc': 'Genera tu carnet digital con acceso QR y comienza a entrenar en la sede DUBS.',
      },
    ];

    return Container(
      width: double.infinity,
      color: AppColors.navyBlueDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PROCESO SIMPLE Y RÁPIDO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Inscribirte y Entrenar es Simple',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          for (final s in steps)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryRed),
                    ),
                    child: Center(
                      child: Text(
                        s['step'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['desc'] as String,
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
