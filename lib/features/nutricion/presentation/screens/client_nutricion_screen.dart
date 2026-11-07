import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/nutricion_provider.dart';
import '../widgets/plan_nutricional_card.dart';

class ClientNutricionScreen extends ConsumerStatefulWidget {
  const ClientNutricionScreen({super.key});

  @override
  ConsumerState<ClientNutricionScreen> createState() => _ClientNutricionScreenState();
}

class _ClientNutricionScreenState extends ConsumerState<ClientNutricionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planesAsync = ref.watch(misPlanesAlimentacionFiltradosProvider);
    final filtroEstado = ref.watch(filtroEstadoPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            _buildHeader(context),

            // Search Bar & Filter Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      ref.read(searchNutricionProvider.notifier).setSearch(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar plan por nombre, objetivo...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchNutricionProvider.notifier).setSearch('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF0077D4), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Segmented Filter
                  Row(
                    children: [
                      _buildFilterChip(
                        label: 'Planes Activos',
                        selected: filtroEstado == 'activos',
                        onTap: () {
                          ref.read(filtroEstadoPlanProvider.notifier).setFiltro('activos');
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Todos los Planes',
                        selected: filtroEstado == 'todos',
                        onTap: () {
                          ref.read(filtroEstadoPlanProvider.notifier).setFiltro('todos');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content List / Refresh
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF0077D4),
                onRefresh: () async {
                  ref.invalidate(planesAlimentacionProvider);
                },
                child: planesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0077D4)),
                  ),
                  error: (err, _) => ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off, size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar planes: $err',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => ref.invalidate(planesAlimentacionProvider),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077D4),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  data: (planes) {
                    if (planes.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: planes.length,
                      itemBuilder: (context, index) {
                        final plan = planes[index];
                        return PlanNutricionalCard(
                          plan: plan,
                          onTap: () {
                            ref
                                .read(planNutricionalSeleccionadoProvider.notifier)
                                .seleccionar(plan);
                            context.push('/client/nutricion/${plan.id}');
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/client/nutricion/generar-ia');
        },
        backgroundColor: const Color(0xFF0077D4),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.auto_awesome, size: 20),
        label: const Text(
          'Generar con IA',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0077D4), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0077D4).withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLANES NUTRICIONALES',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Prescripción inteligente DUBSS & Gemini IA',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
            tooltip: 'Volver',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0077D4) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF0077D4) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
            ),
            child: const Icon(
              Icons.restaurant_menu_outlined,
              color: Color(0xFF0077D4),
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No tienes planes de alimentación activos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Genera tu plan personalizado con Inteligencia Artificial adaptado a tus medidas, objetivos deportivos y presupuesto accesible.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/client/nutricion/generar-ia');
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Generar Plan con Gemini IA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077D4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
