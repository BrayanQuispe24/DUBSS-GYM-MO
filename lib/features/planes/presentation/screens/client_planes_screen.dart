import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/planes_providers.dart';
import '../widgets/plan_card_widget.dart';

class ClientPlanesScreen extends ConsumerWidget {
  const ClientPlanesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredPlanesAsync = ref.watch(filteredPlanesProvider);
    final activeFilter = ref.watch(planFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      body: RefreshIndicator(
        color: AppColors.accentVibrant,
        backgroundColor: AppColors.carbonSurface,
        onRefresh: () async {
          ref.invalidate(planesListProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Diamond Icon Box
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                          ),
                          child: const Icon(
                            Icons.diamond_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'GESTIÓN DE MEMBRESÍAS & TARIFAS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textWhite,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Subtitle
                    const Text(
                      'Catálogo institucional de planes de suscripción, periodos de vigencia y aranceles universitarios.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSlateMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Todos',
                            value: 'todos',
                            current: activeFilter,
                            onTap: () => ref.read(planFilterProvider.notifier).setFilter('todos'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Estudiantes',
                            value: 'estudiantes',
                            current: activeFilter,
                            onTap: () => ref.read(planFilterProvider.notifier).setFilter('estudiantes'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Administrativos',
                            value: 'administrativos',
                            current: activeFilter,
                            onTap: () => ref.read(planFilterProvider.notifier).setFilter('administrativos'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Docentes',
                            value: 'docentes',
                            current: activeFilter,
                            onTap: () => ref.read(planFilterProvider.notifier).setFilter('docentes'),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Particulares',
                            value: 'particulares',
                            current: activeFilter,
                            onTap: () => ref.read(planFilterProvider.notifier).setFilter('particulares'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Info banner institucional
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.solarGold),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Precios con subvención oficial D.U.B.S. para la comunidad UAGRM.',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSlateLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            filteredPlanesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accentVibrant),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: AppColors.accentVibrant),
                        const SizedBox(height: 12),
                        const Text(
                          'Error al cargar planes de membresía',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(planesListProvider),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryCrimson,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (planes) {
                if (planes.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSlateMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No se encontraron planes',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'No hay planes disponibles para la categoría seleccionada.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => ref.read(planFilterProvider.notifier).setFilter('todos'),
                              child: const Text('Ver todos los planes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final plan = planes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlanCardWidget(
                            plan: plan,
                            onInscribirse: () {
                              final precio = plan.tarifa?.precio ?? '0.00';
                              context.push(
                                '/client/tramites/solicitud?planId=${plan.id}&planNombre=${Uri.encodeComponent(plan.nombre)}&planPrecio=$precio',
                              );
                            },
                          ),
                        );
                      },
                      childCount: planes.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required String current,
    required VoidCallback onTap,
  }) {
    final isSelected = current == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCrimson : AppColors.carbonSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.accentVibrant : AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSlateLight,
          ),
        ),
      ),
    );
  }
}
