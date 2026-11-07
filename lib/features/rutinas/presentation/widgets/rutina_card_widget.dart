import 'package:flutter/material.dart';
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
        return const Color(0xFF10B981);
      case 'intermedio':
        return const Color(0xFF0077D4);
      case 'avanzado':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivelColor = _getNivelColor(rutina.nivel);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top accent color line
            Container(height: 3.5, color: nivelColor),

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
                            color: Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: nivelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: nivelColor.withValues(alpha: 0.25)),
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
                        color: Color(0xFF64748B),
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
                          const Icon(Icons.fitness_center, size: 14, color: Color(0xFF0077D4)),
                          const SizedBox(width: 4),
                          Text(
                            '${rutina.totalEjercicios} ejercicios',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Duration
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '~${rutina.duracionEstimadaMinutos} min',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                      if (rutina.generadoPorIa) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5FF),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFE9D5FF)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 10, color: Color(0xFF9333EA)),
                              SizedBox(width: 2),
                              Text(
                                'IA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF9333EA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Action Button
                      FilledButton.tonal(
                        onPressed: () {
                          RutinaDetailModal.show(context, rutina);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F9FF),
                          foregroundColor: const Color(0xFF0077D4),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Ver Rutina',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 11),
                          ],
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
