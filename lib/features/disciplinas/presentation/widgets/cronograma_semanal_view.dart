import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/disciplina_horario_model.dart';
import '../providers/disciplinas_provider.dart';

class CronogramaSemanalView extends ConsumerWidget {
  const CronogramaSemanalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horariosAsync = ref.watch(cronogramaHorariosFiltradosProvider);
    final diaSeleccionado = ref.watch(cronogramaDiaProvider);

    final dias = [
      'todos',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];

    return Column(
      children: [
        // Horizontal Day Selector Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dias.map((dia) {
                final isSelected = diaSeleccionado == dia;
                final label = dia == 'todos' ? 'Todos los Días' : dia;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSlateLight,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(cronogramaDiaProvider.notifier).setDia(dia);
                    },
                    selectedColor: AppColors.primaryCrimson,
                    backgroundColor: AppColors.carbonSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.accentVibrant
                          : AppColors.borderSubtle,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Turnos List
        Expanded(
          child: horariosAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentVibrant),
            ),
            error: (err, _) => Center(
              child: Text(
                'Error al cargar cronograma: $err',
                style: const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
              ),
            ),
            data: (turnos) {
              if (turnos.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy_outlined,
                              size: 48, color: AppColors.textSlateMuted),
                          SizedBox(height: 12),
                          Text(
                            'No hay clases programadas para este filtro',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Prueba seleccionando otro día o ajustando el término de búsqueda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                itemCount: turnos.length,
                itemBuilder: (context, index) {
                  return _buildTurnoCard(turnos[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTurnoCard(DisciplinaHorarioModel turno) {
    final hor = turno.horario;
    final horas = hor?.horarioFormateado ?? '00:00 - 00:00';
    final dia = hor?.diaSemana ?? 'Días no especificados';
    final nombre = turno.disciplinaNombre ?? 'Disciplina Deportiva';
    final tieneCupos = turno.tieneCupos;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Time Badge Column
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.carbonSurfaceMuted,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.accentVibrant),
                  const SizedBox(height: 3),
                  Text(
                    horas,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accentVibrant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Class info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 13, color: AppColors.textSlateMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dia,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSlateLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        tieneCupos ? Icons.check_circle_outline : Icons.cancel_outlined,
                        size: 12,
                        color: tieneCupos
                            ? AppColors.successEmerald
                            : AppColors.accentVibrant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${turno.cuposDisponibles} de ${turno.cupoMaximo} cupos disponibles',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tieneCupos
                              ? AppColors.successLight
                              : AppColors.accentVibrant,
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
