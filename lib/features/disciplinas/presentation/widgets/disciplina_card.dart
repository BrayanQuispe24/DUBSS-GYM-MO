import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      occupancyColor = AppColors.accentVibrant; // Rojo Carmin
    } else if (ratio >= 0.70) {
      occupancyColor = AppColors.solarAmber; // Ámbar Solar
    } else {
      occupancyColor = AppColors.successEmerald; // Verde Esmeralda
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            // Top Accent Bar (Crimson o Muted)
            Container(
              height: 3.0,
              color: isActive ? AppColors.accentVibrant : AppColors.borderSubtle,
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
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Icon(
                          _getIconForDisciplina(disciplina.nombre),
                          color: AppColors.accentVibrant,
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
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${disciplina.disciplinaHorarios.length} turnos programados',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSlateMuted,
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
                        color: AppColors.textSlateLight,
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
                              const Text(
                                'Ocupación de Sala:',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSlateLight,
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
                          backgroundColor: AppColors.carbonSurfaceMuted,
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
                            color: AppColors.carbonSurfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, size: 11, color: AppColors.accentVibrant),
                              const SizedBox(width: 4),
                              Text(
                                dia,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSlateLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderSubtle),
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
                            color: totalDisp > 0 ? AppColors.successEmerald : AppColors.accentVibrant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            totalDisp > 0 ? '$totalDisp cupos libres' : 'Cupos completos',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: totalDisp > 0 ? AppColors.successLight : AppColors.accentVibrant,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () => DisciplinaDetailModal.show(context, disciplina),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentVibrant,
                          side: const BorderSide(color: AppColors.accentVibrant),
                          backgroundColor: AppColors.carbonSurfaceMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
