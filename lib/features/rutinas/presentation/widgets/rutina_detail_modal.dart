import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => RutinaDetailModal(rutina: rutina),
    );
  }

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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
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
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFF0077D4),
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
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: nivelColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
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
                            if (rutina.generadoPorIa) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFE9D5FF)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome, size: 10, color: Color(0xFF9333EA)),
                                    SizedBox(width: 3),
                                    Text(
                                      'IA',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF9333EA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Meta Stats Badges
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.list_alt,
                        label: '${rutina.totalEjercicios} Ejercicios',
                        color: const Color(0xFF0077D4),
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        icon: Icons.timer_outlined,
                        label: '~${rutina.duracionEstimadaMinutos} min',
                        color: const Color(0xFF0284C7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description if any
                  if (rutina.descripcion != null &&
                      rutina.descripcion!.trim().isNotEmpty) ...[
                    Text(
                      rutina.descripcion!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // IA Rules Justification Banner
                  if (rutina.generadoPorIa && rutina.justificacionReglas.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: Color(0xFF9333EA)),
                              SizedBox(width: 6),
                              Text(
                                'Prescripción Basada en IA',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7E22CE),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...rutina.justificacionReglas.map(
                            (regla) => Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Color(0xFF9333EA))),
                                  Expanded(
                                    child: Text(
                                      regla,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF6B21A8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section Title: Exercises
                  const Text(
                    'EJERCICIOS PROGRAMADOS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (rutina.rutinaEjercicios.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'Esta rutina no tiene ejercicios asignados aún.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
