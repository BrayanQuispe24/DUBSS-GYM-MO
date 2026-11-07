import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
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
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Gimnasio UAGRM / Deporte & Entrenamiento',
              style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune, color: Color(0xFF0077D4)),
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
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0077D4),
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
                            color: const Color(0xFF003B70),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Catálogo de Ejercicios & Musculación',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0B1727),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Explora los ejercicios disponibles, técnicas de ejecución y demostraciones visuales.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),

                    // Search Input
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(ejerciciosFilterProvider.notifier).setSearchDebounced(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o descripción...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF0077D4)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(ejerciciosFilterProvider.notifier).setSearchDebounced('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF0077D4), width: 1.5),
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
                              color: Color(0xFF334155),
                            ),
                          ),
                          loading: () => const Text(
                            'Cargando catálogo...',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                                color: Color(0xFFDC2626),
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
                            const Icon(Icons.search_off_rounded, size: 52, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            const Text(
                              'No se encontraron ejercicios coincidentes',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Intente cambiar los términos de búsqueda o limpiar los filtros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                ref.read(ejerciciosFilterProvider.notifier).reset();
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077D4)),
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
                                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0077D4)),
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
                      CircularProgressIndicator(color: Color(0xFF0077D4)),
                      SizedBox(height: 14),
                      Text(
                        'Cargando catálogo de ejercicios UAGRM...',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                        const Icon(Icons.cloud_off, size: 48, color: Color(0xFFDC2626)),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudo conectar con el catálogo de ejercicios',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(ejerciciosPaginatorProvider.notifier).refresh(),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077D4)),
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
