import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/inventario_provider.dart';

class AmbientesScreen extends ConsumerStatefulWidget {
  const AmbientesScreen({super.key});

  @override
  ConsumerState<AmbientesScreen> createState() => _AmbientesScreenState();
}

class _AmbientesScreenState extends ConsumerState<AmbientesScreen> {
  void _abrirModalAmbiente([AmbienteModel? amb]) {
    final nombreCtrl = TextEditingController(text: amb?.nombre ?? '');
    final descCtrl = TextEditingController(text: amb?.descripcion ?? '');
    String estado = amb?.estado ?? 'operativo';

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
                amb != null ? 'Editar Ambiente / Sala' : 'Nueva Sala o Ambiente',
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
                  labelText: 'Nombre de la Sala / Espacio *',
                  hintText: 'Ej: Sala de Musculación, Área Cardio...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Ubicación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: estado,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Estado Operativo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'operativo', child: Text('Operativo / Disponible')),
                  DropdownMenuItem(value: 'mantenimiento', child: Text('En Mantenimiento')),
                ],
                onChanged: (val) => setModalState(() => estado = val ?? 'operativo'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nombreCtrl.text.trim().isEmpty) return;
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(ctx);

                  final ok = await ref
                      .read(inventarioNotifierProvider.notifier)
                      .guardarAmbiente(
                        id: amb?.id,
                        nombre: nombreCtrl.text.trim(),
                        descripcion: descCtrl.text.trim(),
                        estado: estado,
                      );
                  if (ok && mounted) {
                    nav.pop();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(amb != null ? 'Sala actualizada' : 'Sala registrada'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(amb != null ? 'Actualizar Sala' : 'Crear Sala'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventarioNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Ambientes & Espacios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () =>
                ref.read(inventarioNotifierProvider.notifier).cargarTodo(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalAmbiente(),
        backgroundColor: const Color(0xFF003B70),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nueva Sala',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.navyBlue),
            )
          : state.ambientes.isEmpty
              ? const Center(
                  child: Text(
                    'No hay ambientes registrados en el sistema',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.ambientes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final amb = state.ambientes[index];
                    final isOp = amb.isOperativo;
                    final totalEquipos = state.equipos
                        .where((e) => e.idAmbiente == amb.id)
                        .length;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isOp
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.meeting_room_outlined,
                              color: isOp
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      amb.nombre,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOp
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isOp ? 'OPERATIVO' : 'MANTENIMIENTO',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: isOp
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (amb.descripcion != null &&
                                    amb.descripcion!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    amb.descripcion!,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Equipos en sala: $totalEquipos máquinas',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF0077D4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Color(0xFF003B70), size: 20),
                            onPressed: () => _abrirModalAmbiente(amb),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
