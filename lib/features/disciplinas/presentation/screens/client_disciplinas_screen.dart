import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tramites/presentation/widgets/formulario_dubss_create_modal.dart';
import '../../data/models/disciplina_model.dart';
import '../providers/disciplinas_provider.dart';
import '../widgets/cronograma_semanal_view.dart';
import '../widgets/disciplina_card.dart';

class ClientDisciplinasScreen extends ConsumerStatefulWidget {
  const ClientDisciplinasScreen({super.key});

  @override
  ConsumerState<ClientDisciplinasScreen> createState() =>
      _ClientDisciplinasScreenState();
}

class _ClientDisciplinasScreenState
    extends ConsumerState<ClientDisciplinasScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modoVista = ref.watch(disciplinaVistaModoProvider);
    final disciplinasAsync = ref.watch(disciplinasFiltradasProvider);
    final filtroDisp = ref.watch(disciplinasDisponibilidadProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => FormularioDubssCreateModal.show(context),
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1),
        ),
        icon: const Icon(Icons.add_task, size: 18),
        label: const Text(
          'Inscribirme',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            _buildHeader(context),

            // Segmented View Switcher: Catálogo vs Cronograma
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.carbonSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildViewTabButton(
                      title: 'Catálogo Disciplinas',
                      icon: Icons.sports_kabaddi,
                      isSelected: modoVista == 0,
                      onTap: () =>
                          ref.read(disciplinaVistaModoProvider.notifier).setModo(0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildViewTabButton(
                      title: 'Cronograma Turnos',
                      icon: Icons.calendar_month,
                      isSelected: modoVista == 1,
                      onTap: () =>
                          ref.read(disciplinaVistaModoProvider.notifier).setModo(1),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                onChanged: (val) {
                  ref.read(disciplinasSearchProvider.notifier).setSearch(val);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar disciplina, arte marcial, horario...',
                  hintStyle:
                      const TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                  prefixIcon:
                      const Icon(Icons.search, size: 18, color: AppColors.textSlateMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(disciplinasSearchProvider.notifier)
                                .setSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.carbonSurfaceMuted,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    borderSide:
                        const BorderSide(color: AppColors.accentVibrant, width: 1.5),
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: modoVista == 0
                  ? _buildCatalogoTab(disciplinasAsync, filtroDisp)
                  : const CronogramaSemanalView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.obsidianBase,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.textWhite),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'DISCIPLINAS & HORARIOS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textWhite,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Catálogo deportivo, cupos y turnos UAGRM',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.carbonSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: IconButton(
              onPressed: () {
                ref.invalidate(disciplinasListProvider);
                ref.invalidate(disciplinasHorariosListProvider);
              },
              icon: const Icon(Icons.refresh, size: 18, color: AppColors.accentVibrant),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              tooltip: 'Actualizar Catálogo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCrimson : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: AppColors.accentVibrant)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textSlateMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSlateLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogoTab(
    AsyncValue<List<DisciplinaModel>> disciplinasAsync,
    String filtroDisp,
  ) {
    return RefreshIndicator(
      color: AppColors.accentVibrant,
      backgroundColor: AppColors.carbonSurface,
      onRefresh: () async {
        ref.invalidate(disciplinasListProvider);
      },
      child: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('Todas', 'todos', filtroDisp),
                const SizedBox(width: 6),
                _buildFilterChip('Con Cupos', 'con_cupos', filtroDisp),
                const SizedBox(width: 6),
                _buildFilterChip('Activas', 'activas', filtroDisp),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Disciplinas List
          Expanded(
            child: disciplinasAsync.when(
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
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.accentVibrant),
                        const SizedBox(height: 12),
                        Text(
                          'Error al cargar disciplinas: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSlateMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(disciplinasListProvider),
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
              data: (disciplinas) {
                if (disciplinas.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.sports_gymnastics,
                                size: 48, color: AppColors.textSlateMuted),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron disciplinas',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textWhite,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Intenta modificando el filtro de búsqueda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.5, color: AppColors.textSlateMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                  itemCount: disciplinas.length,
                  itemBuilder: (context, index) {
                    return DisciplinaCard(disciplina: disciplinas[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String current) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSlateLight,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        ref.read(disciplinasDisponibilidadProvider.notifier).setFilter(value);
      },
      selectedColor: AppColors.primaryCrimson,
      backgroundColor: AppColors.carbonSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(
        color: isSelected ? AppColors.accentVibrant : AppColors.borderSubtle,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
