import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.obsidianBase,
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
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                    onChanged: (val) {
                      ref.read(searchNutricionProvider.notifier).setSearch(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar plan por nombre, objetivo...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSlateMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(searchNutricionProvider.notifier).setSearch('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.carbonSurfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                color: AppColors.accentVibrant,
                backgroundColor: AppColors.carbonSurface,
                onRefresh: () async {
                  ref.invalidate(planesAlimentacionProvider);
                },
                child: planesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.accentVibrant),
                  ),
                  error: (err, _) => ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_off, size: 48, color: AppColors.accentVibrant),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar planes: $err',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => ref.invalidate(planesAlimentacionProvider),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryCrimson,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
        icon: const Icon(Icons.auto_awesome, size: 20, color: AppColors.solarGold),
        label: const Text(
          'Generar con IA',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.obsidianBase,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.carbonSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.accentVibrant,
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
                      color: AppColors.textWhite,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Prescripción inteligente DUBSS & Gemini IA',
                    style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: AppColors.textSlateMuted),
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryCrimson : AppColors.carbonSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppColors.accentVibrant : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSlateLight,
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
              color: AppColors.carbonSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle, width: 1.0),
            ),
            child: const Icon(
              Icons.restaurant_menu_outlined,
              color: AppColors.accentVibrant,
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
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Genera tu plan personalizado con Inteligencia Artificial adaptado a tus medidas, objetivos deportivos y presupuesto accesible.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSlateMuted, height: 1.4),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/client/nutricion/generar-ia');
            },
            icon: const Icon(Icons.auto_awesome, size: 18, color: AppColors.solarGold),
            label: const Text('Generar Plan con Gemini IA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCrimson,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ],
    );
  }
}
