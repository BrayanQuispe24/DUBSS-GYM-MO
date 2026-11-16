import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/disciplinas_admin_provider.dart';

class DisciplinasAdminScreen extends ConsumerStatefulWidget {
  const DisciplinasAdminScreen({super.key});

  @override
  ConsumerState<DisciplinasAdminScreen> createState() =>
      _DisciplinasAdminScreenState();
}

class _DisciplinasAdminScreenState
    extends ConsumerState<DisciplinasAdminScreen> {
  void _abrirModalDisciplina([AdminDisciplinaItem? disc]) {
    final nombreCtrl = TextEditingController(text: disc?.nombre ?? '');
    final descCtrl = TextEditingController(text: disc?.descripcion ?? '');
    final cuposCtrl =
        TextEditingController(text: '${disc?.cantidadCupos ?? 30}');
    String estado = disc?.estado ?? 'activo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.carbonSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1.0)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                disc != null ? 'Editar Disciplina' : 'Nueva Disciplina Deportiva',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nombreCtrl,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: _inputDeco('Nombre de la Disciplina *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cuposCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: _inputDeco('Capacidad Total de Cupos *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: _inputDeco('Descripción / Requisitos'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nombreCtrl.text.trim().isEmpty) return;
                  final cupos = int.tryParse(cuposCtrl.text.trim()) ?? 30;
                  final nav = Navigator.of(ctx);
                  final ok = await ref
                      .read(disciplinasAdminNotifierProvider.notifier)
                      .guardarDisciplina(
                        id: disc?.id,
                        nombre: nombreCtrl.text.trim(),
                        descripcion: descCtrl.text.trim(),
                        cantidadCupos: cupos,
                        estado: estado,
                      );
                  if (ok && ctx.mounted) {
                    nav.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: AppColors.accentVibrant),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  disc != null ? 'Actualizar Disciplina' : 'Crear Disciplina',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirModalAsignarHorario(AdminDisciplinaItem disc) {
    int? selectedHorarioId;
    final cupoMaxCtrl = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final horarios =
              ref.read(disciplinasAdminNotifierProvider).horarios;

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.carbonSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1.0)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Asignar Turno a: ${disc.nombre}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: selectedHorarioId,
                  dropdownColor: AppColors.carbonSurface,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                  isExpanded: true,
                  decoration: _inputDeco('Bloque Horario'),
                  hint: const Text('Seleccione un turno...', style: TextStyle(color: AppColors.textSlateMuted)),
                  items: horarios
                      .map((h) => DropdownMenuItem(
                            value: h.id,
                            child: Text(
                                '${h.diaSemana}: ${h.horaInicio} - ${h.horaFin}'),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedHorarioId = val),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cupoMaxCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                  decoration: _inputDeco('Cupo Máximo para este Turno *'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedHorarioId == null) return;
                    final cupo = int.tryParse(cupoMaxCtrl.text.trim()) ?? 20;
                    final nav = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await ref
                        .read(disciplinasAdminNotifierProvider.notifier)
                        .asignarHorarioADisciplina(
                          idDisciplina: disc.id,
                          idHorario: selectedHorarioId!,
                          cupoMaximo: cupo,
                        );
                    if (ok && ctx.mounted) {
                      nav.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Turno asignado exitosamente'),
                          backgroundColor: AppColors.successEmerald,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCrimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: AppColors.accentVibrant),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Confirmar Asignación', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(disciplinasAdminNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Disciplinas & Horarios',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSlateLight),
            onPressed: () => ref
                .read(disciplinasAdminNotifierProvider.notifier)
                .cargarTodo(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalDisciplina(),
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nueva Disciplina',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentVibrant),
            )
          : state.disciplinas.isEmpty
              ? const Center(
                  child: Text('No hay disciplinas registradas', style: TextStyle(color: AppColors.textSlateMuted)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.disciplinas.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final d = state.disciplinas[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d.nombre,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.carbonSurfaceMuted,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.successEmerald.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'Cupos: ${d.totalDisponibles}/${d.cantidadCupos}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.successEmerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (d.descripcion != null &&
                              d.descripcion!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              d.descripcion!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSlateLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Turnos asignados: ${d.disciplinaHorarios.length}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.solarGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _abrirModalAsignarHorario(d),
                                icon: const Icon(Icons.schedule, size: 15, color: AppColors.textSlateLight),
                                label: const Text('Asignar Turno',
                                    style: TextStyle(fontSize: 11, color: AppColors.textWhite)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.borderSubtle),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: AppColors.solarGold),
                                onPressed: () => _abrirModalDisciplina(d),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
      filled: true,
      fillColor: AppColors.carbonSurfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.accentVibrant, width: 1.5),
      ),
    );
  }
}
