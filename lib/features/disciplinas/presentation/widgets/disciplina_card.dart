import 'package:flutter/material.dart';
import '../../data/models/disciplina_model.dart';
import 'disciplina_detail_modal.dart';

class DisciplinaCard extends StatelessWidget {
  final DisciplinaModel disciplina;

  const DisciplinaCard({
    super.key,
    required this.disciplina,
  });

  IconData _getIconForDisciplina(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('box') || n.contains('kick')) {
      return Icons.sports_mma;
    } else if (n.contains('aparato') || n.contains('muscul') || n.contains('pesas')) {
      return Icons.fitness_center;
    } else if (n.contains('cardio') || n.contains('spin') || n.contains('bici')) {
      return Icons.directions_bike;
    } else if (n.contains('basket') || n.contains('balon')) {
      return Icons.sports_basketball;
    } else if (n.contains('yoga') || n.contains('pilates')) {
      return Icons.self_improvement;
    }
    return Icons.sports_gymnastics;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = disciplina.isActive;
    final totalMax = disciplina.cuposTotales;
    final totalOcupados = disciplina.totalCuposOcupados;
    final totalDisp = disciplina.totalCuposDisponibles;
    final ratio = disciplina.porcentajeOcupacion;

    final Color occupancyColor;
    if (ratio >= 0.95) {
      occupancyColor = const Color(0xFFDC2626); // Rojo
    } else if (ratio >= 0.70) {
      occupancyColor = const Color(0xFFD97706); // Ámbar
    } else {
      occupancyColor = const Color(0xFF10B981); // Verde
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Bar
            Container(
              height: 3.5,
              color: isActive ? const Color(0xFF0077D4) : const Color(0xFF94A3B8),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Icon + Name + Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Icon(
                          _getIconForDisciplina(disciplina.nombre),
                          color: const Color(0xFF003B70),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disciplina.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${disciplina.disciplinaHorarios.length} turnos programados',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isActive ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Text(
                          isActive ? 'ACTIVA' : 'INACTIVA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isActive ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Descripción si existe
                  if (disciplina.descripcion != null &&
                      disciplina.descripcion!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      disciplina.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Barra de progreso de cupos
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people_alt_outlined, size: 14, color: occupancyColor),
                              const SizedBox(width: 4),
                              Text(
                                'Ocupación de Sala:',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$totalOcupados / $totalMax cupos (${(ratio * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: occupancyColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(occupancyColor),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Chips de horarios / Días
                  if (disciplina.diasAsignados.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: disciplina.diasAsignados.take(2).map((dia) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 11, color: Color(0xFF0077D4)),
                              const SizedBox(width: 4),
                              Text(
                                dia,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),

                  // Bottom Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            totalDisp > 0 ? Icons.check_circle_outline : Icons.cancel_outlined,
                            size: 14,
                            color: totalDisp > 0 ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            totalDisp > 0 ? '$totalDisp cupos libres' : 'Cupos completos',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: totalDisp > 0 ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () => DisciplinaDetailModal.show(context, disciplina),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0077D4),
                          side: const BorderSide(color: Color(0xFF0077D4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        label: const Text(
                          'Ver Horarios',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
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
