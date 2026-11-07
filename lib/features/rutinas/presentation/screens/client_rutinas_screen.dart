import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Header
            _buildHeader(),

            // Tab Bar Switcher (Mi Plan vs Catálogo)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF0077D4),
                unselectedLabelColor: const Color(0xFF64748B),
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
              color: const Color(0xFF0077D4),
              borderRadius: BorderRadius.circular(8),
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
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'Entrenamiento personalizado DUBSS-GYM',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
      color: const Color(0xFF0077D4),
      onRefresh: () async {
        ref.invalidate(misPlanesUsuarioProvider);
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
                    'Error al cargar tu plan: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(misPlanesUsuarioProvider),
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
            return _buildEmptyPlanView();
          }

          final planSeleccionado = ref.watch(planSeleccionadoProvider);

          // Si el usuario seleccionó un plan para inspeccionar, mostramos su desglose diario
          if (planSeleccionado != null) {
            return _buildActivePlanView(planSeleccionado, showBackButton: true);
          }

          // Si no hay plan seleccionado, mostramos la lista completa de todas las tarjetas
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
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0077D4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF0077D4).withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                '${planes.length} ${planes.length == 1 ? 'plan' : 'planes'}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0077D4),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
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
                            ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                            : const Color(0xFF64748B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isActive ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.history,
                            size: 11,
                            color: isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'PLAN ACTIVO' : 'HISTÓRICO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isActive ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (plan.objetivo != null && plan.objetivo!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077D4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF0077D4).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          plan.objetivo!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0077D4),
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
                    color: Color(0xFF0F172A),
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
                      color: Color(0xFF64748B),
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dia,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
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
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          'Ver Rutina & Días',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0077D4),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Color(0xFF0077D4),
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
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF0077D4),
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
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tu instructor universitario asignará un plan adaptado a tu condición física, o puedes explorar el catálogo general.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(1);
            },
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: const Text('Explorar Rutinas del Catálogo'),
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
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 16, color: Color(0xFF0077D4)),
                      SizedBox(width: 6),
                      Text(
                        'Volver a mis planes',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0077D4),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF0077D4), Color(0xFF005BA6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077D4).withValues(alpha: 0.3),
                  blurRadius: 8,
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
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
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          plan.objetivo!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                if (plan.observacion != null && plan.observacion!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.observacion!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${plan.diasConfigurados.length} días de entrenamiento semanal',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.white,
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
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      '${rutinaDelDia.totalEjercicios} ejercicios',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0077D4),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'No hay ejercicios registrados para este día.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Text(
                    'Selecciona un día arriba para ver tu rutina programada.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
                decoration: InputDecoration(
                  hintText: 'Buscar rutinas por nombre o enfoque...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(rutinasSearchFilterProvider.notifier)
                                .setSearch('');
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
            color: const Color(0xFF0077D4),
            onRefresh: () async {
              ref.invalidate(rutinasCatalogoProvider);
            },
            child: catalogoFiltrado.when(
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
                        const Icon(Icons.error_outline, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'Error al cargar catálogo: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(rutinasCatalogoProvider),
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
              data: (rutinas) {
                if (rutinas.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron rutinas con estos filtros',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
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
      selectedColor: const Color(0xFF0077D4),
      labelStyle: TextStyle(
        fontSize: 11.5,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : const Color(0xFF334155),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF0077D4) : const Color(0xFFCBD5E1),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
    );
  }
}
