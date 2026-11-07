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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
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
                  color: Color(0xFF003B70),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Disciplina *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cuposCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacidad Total de Cupos *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Requisitos',
                  border: OutlineInputBorder(),
                ),
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
                  backgroundColor: const Color(0xFF003B70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(disc != null ? 'Actualizar' : 'Crear Disciplina'),
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
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
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
                    color: Color(0xFF003B70),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: selectedHorarioId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Bloque Horario',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Seleccione un turno...'),
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
                  decoration: const InputDecoration(
                    labelText: 'Cupo Máximo para este Turno *',
                    border: OutlineInputBorder(),
                  ),
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
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirmar Asignación'),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Disciplinas & Horarios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => ref
                .read(disciplinasAdminNotifierProvider.notifier)
                .cargarTodo(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalDisciplina(),
        backgroundColor: const Color(0xFF003B70),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nueva Disciplina',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.navyBlue),
            )
          : state.disciplinas.isEmpty
              ? const Center(child: Text('No hay disciplinas registradas'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.disciplinas.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final d = state.disciplinas[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  color: Color(0xFF003B70),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Cupos: ${d.totalDisponibles}/${d.cantidadCupos}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF15803D),
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
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            'Turnos asignados: ${d.disciplinaHorarios.length}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF0077D4),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _abrirModalAsignarHorario(d),
                                icon: const Icon(Icons.schedule, size: 15),
                                label: const Text('Asignar Turno',
                                    style: TextStyle(fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18, color: Color(0xFF003B70)),
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
}
