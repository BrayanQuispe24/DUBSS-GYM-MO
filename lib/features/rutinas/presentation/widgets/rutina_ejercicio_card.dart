import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ejercicios/presentation/widgets/ejercicio_detail_modal.dart';
import '../../data/models/rutina_ejercicio_model.dart';
import '../providers/rutina_timer_provider.dart';
import 'descanso_timer_dialog.dart';

class RutinaEjercicioCard extends ConsumerWidget {
  final RutinaEjercicioModel rutinaEjercicio;
  final int index;

  const RutinaEjercicioCard({
    super.key,
    required this.rutinaEjercicio,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ejercicio = rutinaEjercicio.ejercicio;
    final nombreEjercicio = ejercicio?.nombre ?? 'Ejercicio #${index + 1}';
    final categoria = ejercicio?.tipoEjercicio?.nombre ?? 'Fuerza';
    final imageUrl = ejercicio?.firstImageUrl;
    final descanso = rutinaEjercicio.descansoSegundos;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order Badge + Image + Title + Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order badge (1, 2, 3...)
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryCrimson,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accentVibrant, width: 0.8),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Thumbnail image
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: AppColors.carbonSurfaceMuted,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppColors.accentVibrant,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.fitness_center,
                              color: AppColors.textSlateMuted,
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.fitness_center,
                            color: AppColors.textSlateMuted,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreEjercicio,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.solarGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Prescription Badges Row (Series x Reps, Peso, Descanso)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                // Series x Reps
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.repeat, size: 14, color: AppColors.accentVibrant),
                      const SizedBox(width: 5),
                      Text(
                        '${rutinaEjercicio.series} Series × ${rutinaEjercicio.repeticiones} Reps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),

                // Peso si existe
                if (rutinaEjercicio.peso != null && rutinaEjercicio.peso! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.scale_outlined, size: 14, color: AppColors.solarGold),
                        const SizedBox(width: 5),
                        Text(
                          '${rutinaEjercicio.peso} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Descanso interactivo (abre el cronómetro)
                InkWell(
                  onTap: () {
                    ref.read(descansoTimerProvider.notifier).start(descanso);
                    DescansoTimerDialog.show(
                      context,
                      segundos: descanso,
                      ejercicioNombre: nombreEjercicio,
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.solarGold),
                        const SizedBox(width: 5),
                        Text(
                          '${descanso}s Descanso',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solarGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Observación del instructor si existe
            if (rutinaEjercicio.observacion != null &&
                rutinaEjercicio.observacion!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.carbonSurfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.solarGold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rutinaEjercicio.observacion!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSlateLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Botón de Ver Guía / Técnica si el ejercicio está disponible
            if (ejercicio != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    EjercicioDetailModal.show(context, ejercicio);
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 15, color: AppColors.accentVibrant),
                  label: const Text(
                    'Ver postura y video',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentVibrant),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
