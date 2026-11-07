import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                    color: const Color(0xFF0077D4),
                    borderRadius: BorderRadius.circular(6),
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
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: const Color(0xFFF1F5F9),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.fitness_center,
                              color: Color(0xFF94A3B8),
                              size: 24,
                            ),
                          )
                        : const Icon(
                            Icons.fitness_center,
                            color: Color(0xFF94A3B8),
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
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          categoria,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
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
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.repeat, size: 14, color: Color(0xFF0077D4)),
                      const SizedBox(width: 5),
                      Text(
                        '${rutinaEjercicio.series} Series × ${rutinaEjercicio.repeticiones} Reps',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
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
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.scale_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 5),
                        Text(
                          '${rutinaEjercicio.peso} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
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
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF0284C7)),
                        const SizedBox(width: 5),
                        Text(
                          '${descanso}s Descanso',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0369A1),
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
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        rutinaEjercicio.observacion!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF92400E),
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
                  icon: const Icon(Icons.visibility_outlined, size: 15),
                  label: const Text(
                    'Ver postura y video',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0077D4),
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
