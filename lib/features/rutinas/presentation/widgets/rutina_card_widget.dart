import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/rutina_model.dart';
import 'rutina_detail_modal.dart';

class RutinaCardWidget extends StatelessWidget {
  final RutinaModel rutina;

  const RutinaCardWidget({
    super.key,
    required this.rutina,
  });

  Color _getNivelColor(String nivel) {
    switch (nivel.toLowerCase()) {
      case 'principiante':
        return AppColors.successEmerald;
      case 'intermedio':
        return AppColors.solarGold;
      case 'avanzado':
        return AppColors.accentVibrant;
      default:
        return AppColors.textSlateMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivelColor = _getNivelColor(rutina.nivel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top accent color line
            Container(height: 3.0, color: nivelColor),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          rutina.nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: nivelColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: nivelColor.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: Text(
                          rutina.nivel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: nivelColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Description if any
                  if (rutina.descripcion != null &&
                      rutina.descripcion!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      rutina.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSlateLight,
                        height: 1.3,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Meta row + Button
                  Row(
                    children: [
                      // Ejercicios count
                      Row(
                        children: [
                          const Icon(Icons.fitness_center, size: 14, color: AppColors.accentVibrant),
                          const SizedBox(width: 4),
                          Text(
                            '${rutina.totalEjercicios} ejercicios',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSlateLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Duration
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppColors.solarGold),
                          const SizedBox(width: 4),
                          Text(
                            '~${rutina.duracionEstimadaMinutos} min',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSlateMuted,
                            ),
                          ),
                        ],
                      ),

                      if (rutina.generadoPorIa) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 10, color: AppColors.accentVibrant),
                              SizedBox(width: 2),
                              Text(
                                'IA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentVibrant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Action Button
                      InkWell(
                        onTap: () => RutinaDetailModal.show(context, rutina),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ver Rutina',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                            ],
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
      ),
    );
  }
}
