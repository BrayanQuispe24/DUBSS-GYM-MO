import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/enterprise_card.dart';
import '../../../../core/widgets/status_badge.dart';

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
        'icon': Icons.qr_code_2,
        'title': 'Inscríbete y Entrena',
        'desc': 'Genera tu carnet digital con acceso QR y comienza a entrenar en la sede DUBS.',
      },
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.obsidianBase,
        border: Border.symmetric(
          horizontal: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          const StatusBadge(
            label: 'PROCESO SIMPLE Y RÁPIDO',
            variant: StatusBadgeVariant.crimson,
          ),
          const SizedBox(height: 12),
          const Text(
            'Inscribirte y Entrenar es Simple',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tres pasos para activar tu membresía subvencionada UAGRM',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSlateMuted,
            ),
          ),
          const SizedBox(height: 22),
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EnterpriseCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.primaryCrimson, width: 1.0),
                      ),
                      child: Center(
                        child: Text(
                          s['step'] as String,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w800,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            s['desc'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSlateLight,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
