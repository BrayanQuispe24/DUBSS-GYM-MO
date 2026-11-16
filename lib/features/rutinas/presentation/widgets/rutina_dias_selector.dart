import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/plan_entrenamiento_model.dart';

class RutinaDiasSelector extends StatelessWidget {
  final PlanEntrenamientoModel plan;
  final String? diaSeleccionado;
  final ValueChanged<String> onDiaSelected;

  const RutinaDiasSelector({
    super.key,
    required this.plan,
    required this.diaSeleccionado,
    required this.onDiaSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dias = plan.diasConfigurados;
    if (dias.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dias.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final dia = dias[index];
          final isSelected = diaSeleccionado?.toLowerCase().trim() == dia.toLowerCase().trim();
          final rutina = plan.rutinaPorDia(dia);
          final totalEjercicios = rutina?.totalEjercicios ?? 0;

          return InkWell(
            onTap: () => onDiaSelected(dia),
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryCrimson : AppColors.carbonSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? AppColors.accentVibrant : AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.textSlateMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dia,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSlateLight,
                    ),
                  ),
                  if (totalEjercicios > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$totalEjercicios',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textSlateLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
