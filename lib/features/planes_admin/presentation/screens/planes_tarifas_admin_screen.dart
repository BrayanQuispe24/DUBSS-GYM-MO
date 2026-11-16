import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/planes_tarifas_provider.dart';

class PlanesTarifasAdminScreen extends ConsumerStatefulWidget {
  const PlanesTarifasAdminScreen({super.key});

  @override
  ConsumerState<PlanesTarifasAdminScreen> createState() =>
      _PlanesTarifasAdminScreenState();
}

class _PlanesTarifasAdminScreenState
    extends ConsumerState<PlanesTarifasAdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _abrirModalPlan([PlanItem? plan]) {
    final nombreCtrl = TextEditingController(text: plan?.nombre ?? '');
    final descCtrl = TextEditingController(text: plan?.descripcion ?? '');
    final duracionCtrl =
        TextEditingController(text: '${plan?.duracionDias ?? 30}');
    int? selectedTarifaId = plan?.idTarifa;
    bool estado = plan?.estado ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final tarifas = ref.read(planesTarifasNotifierProvider).tarifas;

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
                  plan != null ? 'Editar Plan' : 'Nuevo Plan de Membresía',
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
                  decoration: _inputDeco('Nombre del Plan *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: duracionCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                  decoration: _inputDeco('Duración (días) *'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: selectedTarifaId,
                  dropdownColor: AppColors.carbonSurface,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                  isExpanded: true,
                  decoration: _inputDeco('Tarifa / Precio Asociado'),
                  hint: const Text('Seleccionar tarifa...', style: TextStyle(color: AppColors.textSlateMuted)),
                  items: tarifas
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text('${t.nombre} (Bs. ${t.precio})'),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedTarifaId = val),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Plan Activo para Socios',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                  value: estado,
                  activeTrackColor: AppColors.successEmerald,
                  inactiveTrackColor: AppColors.carbonSurfaceMuted,
                  activeColor: Colors.white,
                  onChanged: (val) => setModalState(() => estado = val),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (nombreCtrl.text.trim().isEmpty) return;
                    final nav = Navigator.of(ctx);
                    final ok = await ref
                        .read(planesTarifasNotifierProvider.notifier)
                        .guardarPlan(
                          id: plan?.id,
                          nombre: nombreCtrl.text.trim(),
                          descripcion: descCtrl.text.trim(),
                          duracionDias:
                              int.tryParse(duracionCtrl.text.trim()) ?? 30,
                          idTarifa: selectedTarifaId,
                          estado: estado,
                        );
                    if (ok && mounted) {
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
                    plan != null ? 'Actualizar Plan' : 'Crear Plan',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _abrirModalTarifa([TarifaItem? tarifa]) {
    final nombreCtrl = TextEditingController(text: tarifa?.nombre ?? '');
    final precioCtrl =
        TextEditingController(text: tarifa != null ? '${tarifa.precio}' : '');
    bool estado = tarifa?.estado ?? true;

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
                tarifa != null ? 'Editar Tarifa' : 'Nueva Tarifa Oficial',
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
                decoration: _inputDeco('Nombre de Tarifa *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: _inputDeco('Precio (Bs.) *'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tarifa Habilitada',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                value: estado,
                activeTrackColor: AppColors.successEmerald,
                inactiveTrackColor: AppColors.carbonSurfaceMuted,
                activeColor: Colors.white,
                onChanged: (val) => setModalState(() => estado = val),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nombreCtrl.text.trim().isEmpty) return;
                  final p = double.tryParse(precioCtrl.text.trim()) ?? 0.0;
                  final nav = Navigator.of(ctx);

                  final ok = await ref
                      .read(planesTarifasNotifierProvider.notifier)
                      .guardarTarifa(
                        id: tarifa?.id,
                        nombre: nombreCtrl.text.trim(),
                        precio: p,
                        estado: estado,
                      );
                  if (ok && mounted) {
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
                  tarifa != null ? 'Actualizar Tarifa' : 'Crear Tarifa',
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
    final state = ref.watch(planesTarifasNotifierProvider);

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
          'Planes & Tarifas DUBSS',
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
                .read(planesTarifasNotifierProvider.notifier)
                .cargarTodo(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primaryCrimson,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSlateMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [
            Tab(text: 'Planes (${state.planes.length})'),
            Tab(text: 'Tarifas (${state.tarifas.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabCtrl.index == 0) {
            _abrirModalPlan();
          } else {
            _abrirModalTarifa();
          }
        },
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          _tabCtrl.index == 0 ? 'Nuevo Plan' : 'Nueva Tarifa',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentVibrant),
            )
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildPlanesList(state.planes),
                _buildTarifasList(state.tarifas),
              ],
            ),
    );
  }

  Widget _buildPlanesList(List<PlanItem> planes) {
    if (planes.isEmpty) {
      return const Center(
        child: Text('No hay planes registrados', style: TextStyle(color: AppColors.textSlateMuted)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: planes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = planes[index];
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
                  color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.card_membership_rounded,
                    color: AppColors.solarGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duración: ${p.duracionDias} días • ${p.precioTarifa != null ? 'Bs. ${p.precioTarifa}' : 'Sin arancel'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSlateLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.solarGold),
                onPressed: () => _abrirModalPlan(p),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTarifasList(List<TarifaItem> tarifas) {
    if (tarifas.isEmpty) {
      return const Center(
        child: Text('No hay tarifas registradas', style: TextStyle(color: AppColors.textSlateMuted)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tarifas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = tarifas[index];
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
                  color: AppColors.successEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.successEmerald.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.monetization_on_outlined,
                    color: AppColors.successEmerald, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bs. ${t.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.successEmerald,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.solarGold),
                onPressed: () => _abrirModalTarifa(t),
              ),
            ],
          ),
        );
      },
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
