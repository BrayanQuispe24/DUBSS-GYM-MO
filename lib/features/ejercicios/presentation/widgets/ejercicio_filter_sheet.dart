import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ejercicios_providers.dart';

class EjercicioFilterSheet extends ConsumerStatefulWidget {
  const EjercicioFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const EjercicioFilterSheet(),
    );
  }

  @override
  ConsumerState<EjercicioFilterSheet> createState() => _EjercicioFilterSheetState();
}

class _EjercicioFilterSheetState extends ConsumerState<EjercicioFilterSheet> {
  int? _tempTipoId;
  int? _tempGrupoId;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(ejerciciosFilterProvider);
    _tempTipoId = filter.selectedTipoId;
    _tempGrupoId = filter.selectedGrupoId;
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposEjercicioProvider);
    final gruposAsync = ref.watch(gruposMuscularesProvider);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: 14),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune, color: Color(0xFF0077D4), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Filtros de Ejercicios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempTipoId = null;
                      _tempGrupoId = null;
                    });
                  },
                  child: const Text(
                    'Limpiar',
                    style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Scrollable Content
            Expanded(
              child: ListView(
                children: [
                  // Section: Tipo de Ejercicio
                  const Text(
                    'Tipo de Ejercicio',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  tiposAsync.when(
                    data: (tipos) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tipos.map((t) {
                        final isSelected = _tempTipoId == t.id;
                        return ChoiceChip(
                          label: Text(t.nombre),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0077D4),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF0077D4) : const Color(0xFFCBD5E1),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _tempTipoId = val ? t.id : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (err, stack) => const Text('Error al cargar tipos'),
                  ),

                  const SizedBox(height: 20),

                  // Section: Grupo Muscular
                  const Text(
                    'Grupo Muscular',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  gruposAsync.when(
                    data: (grupos) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: grupos.map((g) {
                        final isSelected = _tempGrupoId == g.id;
                        return ChoiceChip(
                          label: Text(g.nombre),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0077D4),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF0077D4) : const Color(0xFFCBD5E1),
                          ),
                          onSelected: (val) {
                            setState(() {
                              _tempGrupoId = val ? g.id : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (err, stack) => const Text('Error al cargar grupos musculares'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final notifier = ref.read(ejerciciosFilterProvider.notifier);
                  notifier.setTipo(_tempTipoId);
                  notifier.setGrupo(_tempGrupoId);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077D4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Aplicar Filtros',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
