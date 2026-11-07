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
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF0077D4),
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
                            color: const Color(0xFF0077D4),
                            borderRadius: BorderRadius.circular(5),
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
                              color: Color(0xFF0F172A),
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
                        color: Color(0xFF64748B),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // Planes Content
            filteredPlanesAsync.when(
              data: (planes) {
                if (planes.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No se encontraron planes para esta categoría',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(planFilterProvider.notifier).setFilter('todos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077D4),
                              ),
                              child: const Text('Ver todos los planes'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final plan = planes[index];
                        return PlanCardWidget(plan: plan);
                      },
                      childCount: planes.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0077D4)),
                      SizedBox(height: 14),
                      Text(
                        'Cargando catálogo institucional...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 48,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudo conectar con el catálogo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        if (err.toString().contains('Sesión') ||
                            err.toString().contains('autoriz') ||
                            err.toString().contains('401'))
                          ElevatedButton.icon(
                            onPressed: () => context.go('/login'),
                            icon: const Icon(Icons.login, size: 16),
                            label: const Text('Iniciar Sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077D4),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => ref.invalidate(planesListProvider),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077D4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
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
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0077D4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0077D4) : const Color(0xFFCBD5E1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0077D4).withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
