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
                  eq != null ? 'Editar Maquinaria' : 'Nuevo Equipo de Inventario',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite,
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
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDeco('Código Activo *', hint: 'EQ-101'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: nombreCtrl,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDeco('Nombre Equipo *', hint: 'Caminadora Pro'),
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
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDeco('Modelo'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: cantidadCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                                decoration: _inputDeco('Cantidad *'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: precioCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                          decoration: _inputDeco('Precio de Compra (Bs.)'),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: selectedAmbienteId,
                          dropdownColor: AppColors.carbonSurface,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                          isExpanded: true,
                          decoration: _inputDeco('Ambiente / Sala'),
                          hint: const Text('Seleccionar sala...', style: TextStyle(color: AppColors.textSlateMuted)),
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
                          dropdownColor: AppColors.carbonSurface,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                          isExpanded: true,
                          decoration: _inputDeco('Marca'),
                          hint: const Text('Seleccionar marca...', style: TextStyle(color: AppColors.textSlateMuted)),
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
                          dropdownColor: AppColors.carbonSurface,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                          isExpanded: true,
                          decoration: _inputDeco('Estado Operativo'),
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
                    eq != null ? 'Actualizar Equipo' : 'Guardar Equipo',
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
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Inventario de Equipos & Maquinaria',
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
        onPressed: () => _abrirModalEquipo(),
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nuevo Equipo',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: Column(
        children: [
          // FILTROS Y BÚSQUEDA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.carbonSurface,
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar por código, nombre o modelo...',
                    hintStyle:
                        const TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: AppColors.textSlateMuted),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.carbonSurfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
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
                      borderSide: const BorderSide(color: AppColors.accentVibrant),
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
                            selectedColor: AppColors.primaryCrimson,
                            backgroundColor: AppColors.carbonSurfaceMuted,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: _filterAmbienteId == null
                                    ? AppColors.accentVibrant
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: _filterAmbienteId == null
                                  ? Colors.white
                                  : AppColors.textSlateLight,
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
                              selectedColor: AppColors.primaryCrimson,
                              backgroundColor: AppColors.carbonSurfaceMuted,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(
                                  color: _filterAmbienteId == a.id
                                      ? AppColors.accentVibrant
                                      : AppColors.borderSubtle,
                                ),
                              ),
                              labelStyle: TextStyle(
                                color: _filterAmbienteId == a.id
                                    ? Colors.white
                                    : AppColors.textSlateLight,
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

          // LISTA DE EQUIPOS
          Expanded(
            child: state.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.accentVibrant),
                  )
                : filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron equipos',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSlateMuted),
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

                          final badgeBg = isOperativo
                              ? AppColors.successEmerald.withValues(alpha: 0.15)
                              : AppColors.accentVibrant.withValues(alpha: 0.15);
                          final badgeColor = isOperativo
                              ? AppColors.successEmerald
                              : AppColors.accentVibrant;

                          return Container(
                            padding: const EdgeInsets.all(12),
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
                                    border: Border.all(color: AppColors.accentVibrant.withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    color: AppColors.solarGold,
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
                                              color: AppColors.carbonSurfaceMuted,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.borderSubtle),
                                            ),
                                            child: Text(
                                              eq.codigo,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.solarGold,
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
                                                color: AppColors.textWhite,
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
                                          color: AppColors.textSlateLight,
                                        ),
                                      ),
                                      if (eq.nombreMarca != null) ...[
                                        Text(
                                          'Marca: ${eq.nombreMarca}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSlateMuted,
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
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    isOperativo ? 'OK' : 'FALLA',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: badgeColor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: AppColors.solarGold),
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
