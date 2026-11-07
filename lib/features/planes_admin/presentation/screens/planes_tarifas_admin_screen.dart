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
                  plan != null ? 'Editar Plan' : 'Nuevo Plan de Membresía',
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
                    labelText: 'Nombre del Plan *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: duracionCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duración (días) *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: selectedTarifaId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tarifa / Precio Asociado',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Seleccionar tarifa...'),
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
                  title: const Text('Plan Activo para Socios',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  value: estado,
                  activeTrackColor: const Color(0xFF16A34A),
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
                    backgroundColor: const Color(0xFF003B70),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(plan != null ? 'Actualizar' : 'Crear Plan'),
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
                tarifa != null ? 'Editar Tarifa' : 'Nueva Tarifa Oficial',
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
                  labelText: 'Nombre de Tarifa *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: precioCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio (Bs.) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Tarifa Habilitada',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                value: estado,
                activeTrackColor: const Color(0xFF16A34A),
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
                  backgroundColor: const Color(0xFF003B70),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(tarifa != null ? 'Actualizar' : 'Crear Tarifa'),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Planes & Tarifas DUBSS',
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
                .read(planesTarifasNotifierProvider.notifier)
                .cargarTodo(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFD97706),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
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
        backgroundColor: const Color(0xFF003B70),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          _tabCtrl.index == 0 ? 'Nuevo Plan' : 'Nueva Tarifa',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.navyBlue),
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
      return const Center(child: Text('No hay planes registrados'));
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_membership_rounded,
                    color: Color(0xFFD97706), size: 22),
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duración: ${p.duracionDias} días • ${p.precioTarifa != null ? 'Bs. ${p.precioTarifa}' : 'Sin arancel'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF003B70)),
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
      return const Center(child: Text('No hay tarifas registradas'));
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monetization_on_outlined,
                    color: Color(0xFF16A34A), size: 22),
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bs. ${t.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF003B70)),
                onPressed: () => _abrirModalTarifa(t),
              ),
            ],
          ),
        );
      },
    );
  }
}
