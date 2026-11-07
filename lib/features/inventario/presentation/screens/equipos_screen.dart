import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/inventario_provider.dart';

class EquiposScreen extends ConsumerStatefulWidget {
  const EquiposScreen({super.key});

  @override
  ConsumerState<EquiposScreen> createState() => _EquiposScreenState();
}

class _EquiposScreenState extends ConsumerState<EquiposScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int? _filterAmbienteId;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _abrirModalEquipo([EquipoModel? eq]) {
    final codigoCtrl = TextEditingController(text: eq?.codigo ?? '');
    final nombreCtrl = TextEditingController(text: eq?.nombre ?? '');
    final modeloCtrl = TextEditingController(text: eq?.modelo ?? '');
    final cantidadCtrl = TextEditingController(text: '${eq?.cantidad ?? 1}');
    final precioCtrl = TextEditingController(
        text: eq?.precioCompra != null ? '${eq!.precioCompra}' : '');
    int? selectedAmbienteId = eq?.idAmbiente;
    int? selectedMarcaId = eq?.idMarca;
    int? selectedTipoId = eq?.idTipoEquipo;
    String estado = eq?.estado ?? 'operativo';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final inv = ref.read(inventarioNotifierProvider);

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
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
                  eq != null ? 'Editar Maquinaria' : 'Nuevo Equipo de Inventario',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF003B70),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: codigoCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Código Activo *',
                                  hintText: 'EQ-101',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: nombreCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre Equipo *',
                                  hintText: 'Caminadora Pro',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: modeloCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Modelo',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: cantidadCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Cantidad *',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: precioCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio de Compra (Bs.)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: selectedAmbienteId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Ambiente / Sala',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Seleccionar sala...'),
                          items: inv.ambientes
                              .map((a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text(a.nombre),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => selectedAmbienteId = val),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: selectedMarcaId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Marca',
                            border: OutlineInputBorder(),
                          ),
                          hint: const Text('Seleccionar marca...'),
                          items: inv.marcas
                              .map((m) => DropdownMenuItem<int>(
                                    value: m['id'] as int?,
                                    child: Text(m['nombre']?.toString() ?? ''),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => selectedMarcaId = val),
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
                            DropdownMenuItem(value: 'operativo', child: Text('Operativo (En uso)')),
                            DropdownMenuItem(value: 'mantenimiento', child: Text('En Reparación / Mantenimiento')),
                            DropdownMenuItem(value: 'baja', child: Text('Dado de Baja')),
                          ],
                          onChanged: (val) => setModalState(() => estado = val ?? 'operativo'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () async {
                    if (codigoCtrl.text.trim().isEmpty ||
                        nombreCtrl.text.trim().isEmpty) {
                      return;
                    }
                    final cant = int.tryParse(cantidadCtrl.text.trim()) ?? 1;
                    final precio = double.tryParse(precioCtrl.text.trim());
                    final messenger = ScaffoldMessenger.of(context);
                    final nav = Navigator.of(ctx);

                    final ok = await ref
                        .read(inventarioNotifierProvider.notifier)
                        .guardarEquipo(
                          id: eq?.id,
                          codigo: codigoCtrl.text.trim(),
                          nombre: nombreCtrl.text.trim(),
                          modelo: modeloCtrl.text.trim(),
                          cantidad: cant,
                          precioCompra: precio,
                          estado: estado,
                          idAmbiente: selectedAmbienteId,
                          idMarca: selectedMarcaId,
                          idTipoEquipo: selectedTipoId,
                        );

                    if (ok && mounted) {
                      nav.pop();
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(eq != null ? 'Equipo actualizado' : 'Equipo registrado'),
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
                  child: Text(eq != null ? 'Actualizar' : 'Guardar Equipo'),
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
    final state = ref.watch(inventarioNotifierProvider);

    final filtered = state.equipos.where((eq) {
      if (_filterAmbienteId != null && eq.idAmbiente != _filterAmbienteId) {
        return false;
      }
      final q = _searchCtrl.text.toLowerCase().trim();
      if (q.isNotEmpty) {
        final cod = eq.codigo.toLowerCase();
        final nom = eq.nombre.toLowerCase();
        final mod = (eq.modelo ?? '').toLowerCase();
        return cod.contains(q) || nom.contains(q) || mod.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Inventario de Equipos & Maquinaria',
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
        onPressed: () => _abrirModalEquipo(),
        backgroundColor: const Color(0xFF003B70),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nuevo Equipo',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // FILTROS Y BÚSQUEDA
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por código, nombre o modelo...',
                    hintStyle:
                        const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: Color(0xFF64748B)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (state.ambientes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: const Text('Todas las Salas'),
                            selected: _filterAmbienteId == null,
                            onSelected: (_) =>
                                setState(() => _filterAmbienteId = null),
                            selectedColor: const Color(0xFF003B70),
                            labelStyle: TextStyle(
                              color: _filterAmbienteId == null
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontSize: 11,
                              fontWeight: _filterAmbienteId == null
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        ...state.ambientes.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(a.nombre),
                              selected: _filterAmbienteId == a.id,
                              onSelected: (_) =>
                                  setState(() => _filterAmbienteId = a.id),
                              selectedColor: const Color(0xFF003B70),
                              labelStyle: TextStyle(
                                color: _filterAmbienteId == a.id
                                    ? Colors.white
                                    : const Color(0xFF334155),
                                fontSize: 11,
                                fontWeight: _filterAmbienteId == a.id
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // LISTA DE EQUIPOS
          Expanded(
            child: state.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.navyBlue),
                  )
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron equipos',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final eq = filtered[index];
                          final isOperativo =
                              eq.estado.toLowerCase() == 'operativo';

                          return Container(
                            padding: const EdgeInsets.all(12),
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
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    color: Color(0xFF003B70),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0F2FE),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              eq.codigo,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF0369A1),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              eq.nombre,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${eq.nombreAmbiente ?? 'Sin sala'} • Cant: ${eq.cantidad}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      if (eq.nombreMarca != null) ...[
                                        Text(
                                          'Marca: ${eq.nombreMarca}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isOperativo
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isOperativo ? 'OK' : 'FALLA',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: isOperativo
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: Color(0xFF003B70)),
                                  onPressed: () => _abrirModalEquipo(eq),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
