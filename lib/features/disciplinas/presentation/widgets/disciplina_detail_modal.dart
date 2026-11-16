import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
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
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          left: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          right: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
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
                color: AppColors.borderSubtle,
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
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Icon(
                      _getIconForDisciplina(disciplina.nombre),
                      color: AppColors.accentVibrant,
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
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Expediente Deportivo UAGRM • ID #${disciplina.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSlateMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.successEmerald.withValues(alpha: 0.15)
                          : AppColors.accentVibrant.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isActive ? AppColors.successEmerald : AppColors.accentVibrant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isActive ? 'ACTIVA' : 'INACTIVA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isActive ? AppColors.successLight : AppColors.accentVibrant,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSlateMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),

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
                          color: AppColors.textWhite,
                          bg: AppColors.carbonSurfaceMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricBox(
                          label: 'Ocupados',
                          value: '$totalOcupados Alumnos',
                          icon: Icons.person_outline,
                          color: AppColors.solarAmber,
                          bg: AppColors.carbonSurfaceMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricBox(
                          label: 'Disponibles',
                          value: '$totalDisp Libres',
                          icon: Icons.check_circle_outline,
                          color: AppColors.successLight,
                          bg: AppColors.carbonSurfaceMuted,
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
                        color: AppColors.accentVibrant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      disciplina.descripcion!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSlateLight,
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
                      color: AppColors.accentVibrant,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (turnos.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: const Center(
                        child: Text(
                          'No hay horarios específicos asignados para esta disciplina.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
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
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
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
                                          size: 13, color: AppColors.accentVibrant),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          dia,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textWhite,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule,
                                          size: 13, color: AppColors.textSlateMuted),
                                      const SizedBox(width: 5),
                                      Text(
                                        horas,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSlateLight,
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
                                        ? AppColors.successEmerald.withValues(alpha: 0.15)
                                        : AppColors.accentVibrant.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: tieneCupos
                                          ? AppColors.successEmerald
                                          : AppColors.accentVibrant,
                                    ),
                                  ),
                                  child: Text(
                                    tieneCupos ? 'DISPONIBLE' : 'LLENO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: tieneCupos
                                          ? AppColors.successLight
                                          : AppColors.accentVibrant,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dh.cuposDisponibles} de ${dh.cupoMaximo} libres',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSlateMuted,
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
                color: AppColors.carbonSurface,
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: CrimsonButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    FormularioDubssCreateModal.show(context);
                  },
                  icon: const Icon(Icons.assignment_turned_in_outlined, size: 18, color: Colors.white),
                  label: '+ Iniciar Solicitud (DUBSS-FR-03)',
                  style: CrimsonButtonStyle.gradient,
                  height: 46,
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
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
                    color: AppColors.textSlateMuted,
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
