import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/plan_alimentacion_model.dart';

class PlanNutricionalCard extends StatelessWidget {
  final PlanAlimentacionModel plan;
  final VoidCallback onTap;

  const PlanNutricionalCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = plan.estado;
    final totalCal = plan.totalCalorias;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? AppColors.accentVibrant : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.successEmerald.withValues(alpha: 0.15)
                            : AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isActive ? AppColors.successEmerald : AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.history,
                            size: 11,
                            color: isActive ? AppColors.successLight : AppColors.textSlateMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'PLAN OFICIAL ACTIVO' : 'HISTÓRICO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive ? AppColors.successLight : AppColors.textSlateMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (totalCal > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentVibrant.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.accentVibrant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department, size: 12, color: AppColors.accentVibrant),
                            const SizedBox(width: 3),
                            Text(
                              '${totalCal.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentVibrant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: AppColors.accentVibrant,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plan.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),

                // Objetivo pill
                if (plan.objetivo != null && plan.objetivo!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      plan.objetivo!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.solarGold,
                      ),
                    ),
                  ),
                ],

                // Observation summary
                if (plan.observacion != null && plan.observacion!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    plan.observacion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSlateLight,
                      height: 1.35,
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 10),

                // Bottom row: athlete + count of meals + action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 13, color: AppColors.textSlateMuted),
                            const SizedBox(width: 4),
                            Text(
                              plan.usuarioNombre,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSlateLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${plan.detalles.length} ${plan.detalles.length == 1 ? 'comida prescrita' : 'comidas prescritas'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSlateMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Text(
                          'Ver Recetas & Menú',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentVibrant,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: AppColors.accentVibrant),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
