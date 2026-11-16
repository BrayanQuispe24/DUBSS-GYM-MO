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
                amb != null ? 'Editar Ambiente / Sala' : 'Nueva Sala o Ambiente',
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
                decoration: _inputDeco('Nombre de la Sala / Espacio *',
                    hint: 'Ej: Sala de Musculación, Área Cardio...'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: _inputDeco('Descripción / Ubicación'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: estado,
                dropdownColor: AppColors.carbonSurface,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                isExpanded: true,
                decoration: _inputDeco('Estado Operativo'),
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
                child: Text(
                  amb != null ? 'Actualizar Sala' : 'Crear Sala',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
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
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Ambientes & Espacios',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSlateLight),
            onPressed: () =>
                ref.read(inventarioNotifierProvider.notifier).cargarTodo(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalAmbiente(),
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nueva Sala',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentVibrant),
            )
          : state.ambientes.isEmpty
              ? const Center(
                  child: Text(
                    'No hay ambientes registrados en el sistema',
                    style: TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
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

                    final badgeBg = isOp
                        ? AppColors.successEmerald.withValues(alpha: 0.15)
                        : AppColors.accentVibrant.withValues(alpha: 0.15);
                    final badgeColor = isOp ? AppColors.successEmerald : AppColors.accentVibrant;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                            ),
                            child: Icon(
                              Icons.meeting_room_outlined,
                              color: badgeColor,
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
                                        color: AppColors.textWhite,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        isOp ? 'OPERATIVO' : 'MANTENIMIENTO',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: badgeColor,
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
                                      color: AppColors.textSlateLight,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Equipos en sala: $totalEquipos máquinas',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.solarGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: AppColors.solarGold, size: 20),
                            onPressed: () => _abrirModalAmbiente(amb),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  InputDecoration _inputDeco(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
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
