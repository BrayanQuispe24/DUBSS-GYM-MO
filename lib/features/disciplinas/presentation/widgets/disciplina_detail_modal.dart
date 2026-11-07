import 'package:flutter/material.dart';
import '../../../tramites/presentation/widgets/formulario_dubss_create_modal.dart';
import '../../data/models/disciplina_model.dart';

class DisciplinaDetailModal extends StatelessWidget {
  final DisciplinaModel disciplina;

  const DisciplinaDetailModal({
    super.key,
    required this.disciplina,
  });

  static Future<void> show(BuildContext context, DisciplinaModel disciplina) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DisciplinaDetailModal(disciplina: disciplina),
    );
  }

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
    }
    return Icons.sports_gymnastics;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = disciplina.isActive;
    final totalMax = disciplina.cuposTotales;
    final totalOcupados = disciplina.totalCuposOcupados;
    final totalDisp = disciplina.totalCuposDisponibles;
    final turnos = disciplina.disciplinaHorarios;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Icon(
                      _getIconForDisciplina(disciplina.nombre),
                      color: const Color(0xFF003B70),
                      size: 24,
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
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Expediente Deportivo UAGRM • ID #${disciplina.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Content Scroll
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Métricas de capacidad (3 Boxes)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBox(
                          label: 'Capacidad Máx.',
                          value: '$totalMax Cupos',
                          icon: Icons.groups_outlined,
                          color: const Color(0xFF003B70),
                          bg: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricBox(
                          label: 'Ocupados',
                          value: '$totalOcupados Alumnos',
                          icon: Icons.person_outline,
                          color: const Color(0xFFD97706),
                          bg: const Color(0xFFFFFBEB),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricBox(
                          label: 'Disponibles',
                          value: '$totalDisp Libres',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF10B981),
                          bg: const Color(0xFFECFDF5),
                        ),
                      ),
                    ],
                  ),

                  // Descripción
                  if (disciplina.descripcion != null &&
                      disciplina.descripcion!.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'Descripción y Enfoque Deportivo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF003B70),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      disciplina.descripcion!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text(
                    'Turnos y Horarios Programados',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF003B70),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (turnos.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay horarios específicos asignados para esta disciplina.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ] else ...[
                    ...turnos.map((dh) {
                      final hor = dh.horario;
                      final dia = hor?.diaSemana ?? 'Días no especificados';
                      final horas = hor?.horarioFormateado ?? '00:00 - 00:00';
                      final tieneCupos = dh.tieneCupos;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 13, color: Color(0xFF0077D4)),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          dia,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule,
                                          size: 13, color: Color(0xFF64748B)),
                                      const SizedBox(width: 5),
                                      Text(
                                        horas,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: tieneCupos
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: tieneCupos
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Text(
                                    tieneCupos ? 'DISPONIBLE' : 'LLENO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: tieneCupos
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dh.cuposDisponibles} de ${dh.cupoMaximo} libres',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom CTA Button: Crear Solicitud DUBSS-FR-03
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FormularioDubssCreateModal.show(context);
                  },
                  icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
                  label: const Text(
                    '+ Iniciar Solicitud (DUBSS-FR-03)',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0077D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
