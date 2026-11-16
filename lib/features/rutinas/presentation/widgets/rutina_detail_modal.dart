import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/rutina_model.dart';
import 'rutina_ejercicio_card.dart';

class RutinaDetailModal extends StatelessWidget {
  final RutinaModel rutina;

  const RutinaDetailModal({
    super.key,
    required this.rutina,
  });

  static Future<void> show(BuildContext context, RutinaModel rutina) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.carbonSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
            left: BorderSide(color: AppColors.borderSubtle, width: 1.0),
            right: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          ),
        ),
        child: RutinaDetailModal(rutina: rutina),
      ),
    );
  }

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

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.accentVibrant, width: 0.8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rutina.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              rutina.nivel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: nivelColor,
                              ),
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textSlateMuted)),
                            Text(
                              '${rutina.totalEjercicios} ejercicios',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSlateLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSlateMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.borderSubtle, height: 1),

            // Content List
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  if (rutina.descripcion != null &&
                      rutina.descripcion!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        rutina.descripcion!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSlateLight,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Ejercicios
                  const Text(
                    'EJERCICIOS PROGRAMADOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSlateMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (rutina.rutinaEjercicios.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Text(
                        'No hay ejercicios configurados para esta rutina.',
                        style: TextStyle(color: AppColors.textSlateMuted),
                      ),
                    )
                  else
                    ...List.generate(
                      rutina.rutinaEjercicios.length,
                      (idx) => RutinaEjercicioCard(
                        rutinaEjercicio: rutina.rutinaEjercicios[idx],
                        index: idx,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
