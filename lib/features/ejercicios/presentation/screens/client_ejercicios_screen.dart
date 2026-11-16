import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/ejercicios_providers.dart';
import '../widgets/ejercicio_card_widget.dart';
import '../widgets/ejercicio_filter_sheet.dart';

class ClientEjerciciosScreen extends ConsumerStatefulWidget {
  const ClientEjerciciosScreen({super.key});

  @override
  ConsumerState<ClientEjerciciosScreen> createState() => _ClientEjerciciosScreenState();
}

class _ClientEjerciciosScreenState extends ConsumerState<ClientEjerciciosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250) {
      ref.read(ejerciciosPaginatorProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(ejerciciosPaginatorProvider);
    final filter = ref.watch(ejerciciosFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo de Ejercicios',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textWhite,
              ),
            ),
            Text(
              'Gimnasio UAGRM / Deporte & Entrenamiento',
              style: TextStyle(fontSize: 10, color: AppColors.textSlateMuted),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: AppColors.accentVibrant),
                tooltip: 'Filtros avanzados',
                onPressed: () => EjercicioFilterSheet.show(context),
              ),
              if (filter.selectedTipoId != null || filter.selectedGrupoId != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accentVibrant,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentVibrant,
        backgroundColor: AppColors.carbonSurface,
        onRefresh: () async {
          await ref.read(ejerciciosPaginatorProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Info & Search Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Title
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.carbonSurface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Icon(Icons.fitness_center, color: AppColors.accentVibrant, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Catálogo de Ejercicios & Musculación',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Explora los ejercicios disponibles, técnicas de ejecución y demostraciones visuales.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSlateMuted),
                    ),
                    const SizedBox(height: 14),

                    // Search Input
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                      onChanged: (val) {
                        ref.read(ejerciciosFilterProvider.notifier).setSearchDebounced(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o descripción...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSlateMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSlateMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(ejerciciosFilterProvider.notifier).setSearchDebounced('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.carbonSurfaceMuted,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                    const SizedBox(height: 12),

                    // Total Count and Active Filter Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        listAsync.when(
                          data: (state) => Text(
                            'Listado de Ejercicios (${state.totalItems} en total)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSlateLight,
                            ),
                          ),
                          loading: () => const Text(
                            'Cargando catálogo...',
                            style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                          ),
                          error: (err, stack) => const SizedBox(),
                        ),
                        if (filter.hasActiveFilters)
                          InkWell(
                            onTap: () {
                              _searchController.clear();
                              ref.read(ejerciciosFilterProvider.notifier).reset();
                            },
                            child: const Text(
                              'Limpiar filtros',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentVibrant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Exercise List Content
            listAsync.when(
              data: (listState) {
                if (listState.items.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 52, color: AppColors.textSlateMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No se encontraron ejercicios coincidentes',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Intente cambiar los términos de búsqueda o limpiar los filtros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                ref.read(ejerciciosFilterProvider.notifier).reset();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryCrimson,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: const Text('Restablecer Filtros', style: TextStyle(color: Colors.white)),
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
                        if (index == listState.items.length) {
                          if (listState.hasReachedEnd) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Has llegado al final del catálogo.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                                ),
                              ),
                            );
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.accentVibrant),
                              ),
                            ),
                          );
                        }

                        final ejercicio = listState.items[index];
                        return EjercicioCardWidget(ejercicio: ejercicio);
                      },
                      childCount: listState.items.length + (listState.hasReachedEnd ? 1 : 1),
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.accentVibrant),
                      SizedBox(height: 14),
                      Text(
                        'Cargando catálogo de ejercicios UAGRM...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
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
                        const Icon(Icons.cloud_off, size: 48, color: AppColors.accentVibrant),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudo conectar con el catálogo de ejercicios',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(ejerciciosPaginatorProvider.notifier).refresh(),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
