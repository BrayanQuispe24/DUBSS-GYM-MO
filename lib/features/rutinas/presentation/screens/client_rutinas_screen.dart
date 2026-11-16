import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../../data/models/plan_entrenamiento_model.dart';
import '../providers/rutinas_provider.dart';
import '../widgets/rutina_card_widget.dart';
import '../widgets/rutina_dias_selector.dart';
import '../widgets/rutina_ejercicio_card.dart';

class ClientRutinasScreen extends ConsumerStatefulWidget {
  const ClientRutinasScreen({super.key});

  @override
  ConsumerState<ClientRutinasScreen> createState() => _ClientRutinasScreenState();
}

class _ClientRutinasScreenState extends ConsumerState<ClientRutinasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Header
            _buildHeader(),

            // Tab Bar Switcher (Mi Plan vs Catálogo)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.carbonSurfaceMuted,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryCrimson,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSlateMuted,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.fitness_center, size: 16),
                    text: 'Mis Planes',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: Icon(Icons.menu_book_outlined, size: 16),
                    text: 'Explorar Catálogo',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMiPlanTab(),
                  _buildCatalogoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryCrimson,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.accentVibrant, width: 1.0),
            ),
            child: const Icon(
              Icons.view_timeline_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RUTINAS DEPORTIVAS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textWhite,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Entrenamiento personalizado DUBSS-GYM',
                style: TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: MI PLAN ACTIVO ---
  Widget _buildMiPlanTab() {
    final planesAsync = ref.watch(misPlanesUsuarioProvider);

    return RefreshIndicator(
      color: AppColors.accentVibrant,
      backgroundColor: AppColors.carbonSurface,
      onRefresh: () async {
        ref.invalidate(misPlanesUsuarioProvider);
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
                  const Icon(Icons.cloud_off, size: 48, color: AppColors.textSlateMuted),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar tu plan: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(misPlanesUsuarioProvider),
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
          ],
        ),
        data: (planes) {
          if (planes.isEmpty) {
            return _buildEmptyPlanView();
          }

          final planSeleccionado = ref.watch(planSeleccionadoProvider);

          if (planSeleccionado != null) {
            return _buildActivePlanView(planSeleccionado, showBackButton: true);
          }

          return _buildPlanesListView(planes);
        },
      ),
    );
  }

  Widget _buildPlanesListView(List<PlanEntrenamientoModel> planes) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PLANES DE ENTRENAMIENTO ASIGNADOS',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textSlateMuted,
                letterSpacing: 0.6,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.accentVibrant, width: 0.8),
              ),
              child: Text(
                '${planes.length} ${planes.length == 1 ? 'plan' : 'planes'}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentVibrant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...planes.map((plan) => _buildPlanCardItem(plan)),
      ],
    );
  }

  Widget _buildPlanCardItem(PlanEntrenamientoModel plan) {
    final isActive = plan.estado;
    final dias = plan.diasConfigurados;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? AppColors.accentVibrant : AppColors.borderSubtle,
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            ref.read(planSeleccionadoProvider.notifier).seleccionarPlan(plan);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.successEmerald.withValues(alpha: 0.15)
                            : AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isActive ? AppColors.successEmerald : AppColors.borderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.history,
                            size: 11,
                            color: isActive ? AppColors.successLight : AppColors.textSlateMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'PLAN ACTIVO' : 'HISTÓRICO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive ? AppColors.successLight : AppColors.textSlateMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (plan.objetivo != null && plan.objetivo!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.solarAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.solarGold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          plan.objetivo!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solarGold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textWhite,
                  ),
                ),
                if (plan.observacion != null && plan.observacion!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.observacion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSlateLight,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (dias.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: dias.map((dia) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                        ),
                        child: Text(
                          dia,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSlateLight,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${dias.length} ${dias.length == 1 ? 'día' : 'días'} de rutina',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSlateMuted,
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          'Ver Rutina & Días',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentVibrant,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: AppColors.accentVibrant,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlanView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.carbonSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle, width: 1.5),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.accentVibrant,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'No tienes un plan de entrenamiento asignado',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tu instructor universitario asignará un plan adaptado a tu condición física, o puedes explorar el catálogo general.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSlateMuted, height: 1.4),
        ),
        const SizedBox(height: 24),
        Center(
          child: CrimsonButton(
            onPressed: () {
              _tabController.animateTo(1);
            },
            icon: const Icon(Icons.explore_outlined, size: 18, color: Colors.white),
            label: 'Explorar Rutinas del Catálogo',
            style: CrimsonButtonStyle.gradient,
            height: 44,
          ),
        ),
      ],
    );
  }

  Widget _buildActivePlanView(PlanEntrenamientoModel plan, {bool showBackButton = false}) {
    final diaSeleccionado = ref.watch(diaSeleccionadoProvider);
    final rutinaDelDia = ref.watch(rutinaDiaSeleccionadoProvider);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        if (showBackButton)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  ref.read(planSeleccionadoProvider.notifier).seleccionarPlan(null);
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 16, color: AppColors.accentVibrant),
                      SizedBox(width: 6),
                      Text(
                        'Volver a mis planes',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentVibrant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Card de Resumen del Plan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.carbonSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.accentVibrant, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentVibrant.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PLAN ASIGNADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (plan.objetivo != null && plan.objetivo!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successEmerald.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.successEmerald, width: 0.8),
                        ),
                        child: Text(
                          plan.objetivo!.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.successLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plan.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textWhite,
                  ),
                ),
                if (plan.observacion != null && plan.observacion!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.observacion!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSlateLight,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.date_range, color: AppColors.solarGold, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${plan.diasConfigurados.length} días de entrenamiento semanal',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSlateLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Selector de Días de la Semana
        RutinaDiasSelector(
          plan: plan,
          diaSeleccionado: diaSeleccionado,
          onDiaSelected: (dia) {
            ref.read(diaSeleccionadoProvider.notifier).seleccionarDia(dia);
          },
        ),

        const SizedBox(height: 16),

        // Ejercicios del Día Seleccionado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rutinaDelDia != null) ...[
                // Rutina Header Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        rutinaDelDia.nombre,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                    Text(
                      '${rutinaDelDia.totalEjercicios} ejercicios',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentVibrant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Lista de Ejercicios
                if (rutinaDelDia.rutinaEjercicios.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Text(
                      'No hay ejercicios registrados para este día.',
                      style: TextStyle(color: AppColors.textSlateMuted, fontSize: 13),
                    ),
                  )
                else
                  ...List.generate(
                    rutinaDelDia.rutinaEjercicios.length,
                    (idx) => RutinaEjercicioCard(
                      rutinaEjercicio: rutinaDelDia.rutinaEjercicios[idx],
                      index: idx,
                    ),
                  ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Text(
                    'Selecciona un día arriba para ver tu rutina programada.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: CATÁLOGO DE RUTINAS ---
  Widget _buildCatalogoTab() {
    final catalogoFiltrado = ref.watch(rutinasCatalogoFiltradasProvider);
    final nivelActual = ref.watch(rutinasNivelFilterProvider);

    return Column(
      children: [
        // Search & Filters Box
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              // Search textfield
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(rutinasSearchFilterProvider.notifier).setSearch(val);
                },
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar rutinas por nombre o enfoque...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSlateMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(rutinasSearchFilterProvider.notifier)
                                .setSearch('');
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

              // Filter Chips by Level
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildNivelChip('todos', 'Todos los Niveles', nivelActual),
                    const SizedBox(width: 6),
                    _buildNivelChip('principiante', 'Principiante', nivelActual),
                    const SizedBox(width: 6),
                    _buildNivelChip('intermedio', 'Intermedio', nivelActual),
                    const SizedBox(width: 6),
                    _buildNivelChip('avanzado', 'Avanzado', nivelActual),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List of Routines
        Expanded(
          child: RefreshIndicator(
            color: AppColors.accentVibrant,
            backgroundColor: AppColors.carbonSurface,
            onRefresh: () async {
              ref.invalidate(rutinasCatalogoProvider);
            },
            child: catalogoFiltrado.when(
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
                        const Icon(Icons.error_outline, size: 48, color: AppColors.accentVibrant),
                        const SizedBox(height: 12),
                        Text(
                          'Error al cargar catálogo: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(rutinasCatalogoProvider),
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
                ],
              ),
              data: (rutinas) {
                if (rutinas.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: AppColors.textSlateMuted),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron rutinas con estos filtros',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSlateLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: rutinas.length,
                  itemBuilder: (context, index) {
                    return RutinaCardWidget(rutina: rutinas[index]);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNivelChip(String valor, String label, String nivelActual) {
    final isSelected = nivelActual == valor;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(rutinasNivelFilterProvider.notifier).setFilter(valor);
        }
      },
      selectedColor: AppColors.primaryCrimson,
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textSlateLight,
      ),
      backgroundColor: AppColors.carbonSurface,
      side: BorderSide(
        color: isSelected ? AppColors.accentVibrant : AppColors.borderSubtle,
        width: 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}
