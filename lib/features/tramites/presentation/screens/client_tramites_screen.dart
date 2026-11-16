import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../providers/tramites_provider.dart';
import '../widgets/boleta_inscripcion_card.dart';
import '../widgets/boleta_pago_card.dart';
import '../widgets/formulario_dubss_create_modal.dart';
import '../widgets/formulario_solicitud_card.dart';
import 'escaner_qr_screen.dart';

class ClientTramitesScreen extends ConsumerStatefulWidget {
  const ClientTramitesScreen({super.key});

  @override
  ConsumerState<ClientTramitesScreen> createState() =>
      _ClientTramitesScreenState();
}

class _ClientTramitesScreenState extends ConsumerState<ClientTramitesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(formulariosSolicitudProvider);
    final boletasAsync = ref.watch(boletasPagoProvider);
    final inscripcionesAsync = ref.watch(boletasInscripcionProvider);

    final solCount = solicitudesAsync.asData?.value.length ?? 0;
    final bolCount = boletasAsync.asData?.value.length ?? 0;
    final insCount = inscripcionesAsync.asData?.value.length ?? 0;

    final currentUser = ref.watch(authNotifierProvider).user;
    final canScanQr = currentUser?.canScanQr ?? false;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      floatingActionButton: canScanQr
          ? FloatingActionButton.extended(
              onPressed: () => EscanerQRScreen.open(context),
              backgroundColor: AppColors.primaryCrimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
              ),
              icon: const Icon(Icons.qr_code_scanner, size: 20),
              label: const Text(
                'Escanear QR',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Header
            _buildHeader(),

            // Tab Bar Switcher (3 Tabs matching Web Frontend)
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
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.assignment_outlined, size: 16),
                    text: 'Solicitudes ($solCount)',
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    text: 'Boletas ($bolCount)',
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: const Icon(Icons.badge_outlined, size: 16),
                    text: 'Pases / Ins. ($insCount)',
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(tramitesSearchFilterProvider.notifier).setSearch(val);
                },
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar por N° formulario, concepto, disciplina...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSlateMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(tramitesSearchFilterProvider.notifier)
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
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFormulariosSolicitudTab(),
                  _buildBoletasPagoTab(),
                  _buildInscripcionesTab(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryCrimson,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accentVibrant, width: 0.8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TRÁMITES & PAGOS',
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
                        'Gestión de solicitudes y boletas',
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
          InkWell(
            onTap: () => FormularioDubssCreateModal.show(context),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.accentVibrant, width: 1.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 15, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Solicitud',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 1: FORMULARIOS DE SOLICITUD (DUBSS-FR-03) ---
  Widget _buildFormulariosSolicitudTab() {
    final solicitudesAsync = ref.watch(formulariosSolicitudFiltradosProvider);
    final estadoFilter = ref.watch(formulariosEstadoFilterProvider);

    return RefreshIndicator(
      color: AppColors.accentVibrant,
      backgroundColor: AppColors.carbonSurface,
      onRefresh: () async {
        ref.invalidate(formulariosSolicitudProvider);
      },
      child: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos', 'todos', estadoFilter),
                  const SizedBox(width: 6),
                  _buildFilterChip('Aprobados', 'aprobado', estadoFilter),
                  const SizedBox(width: 6),
                  _buildFilterChip('Pendientes', 'pendiente', estadoFilter),
                  const SizedBox(width: 6),
                  _buildFilterChip('Rechazados', 'rechazado', estadoFilter),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Solicitudes List
          Expanded(
            child: solicitudesAsync.when(
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
                          'Error al cargar solicitudes: $err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSlateMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              ref.invalidate(formulariosSolicitudProvider),
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
              data: (formularios) {
                if (formularios.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            const Icon(Icons.assignment_outlined,
                                size: 48, color: AppColors.textSlateMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No se encontraron formularios de solicitud',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Puedes enviar una nueva solicitud de ingreso (DUBSS-FR-03) seleccionando tu disciplina y turno preferido.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12.5, color: AppColors.textSlateMuted),
                            ),
                            const SizedBox(height: 18),
                            CrimsonButton(
                              onPressed: () =>
                                  FormularioDubssCreateModal.show(context),
                              icon: const Icon(Icons.add_task, size: 16, color: Colors.white),
                              label: '+ Crear Solicitud (DUBSS-FR-03)',
                              style: CrimsonButtonStyle.gradient,
                              height: 44,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: formularios.length,
                  itemBuilder: (context, index) {
                    return FormularioSolicitudCard(
                        formulario: formularios[index]);
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
        ref.read(formulariosEstadoFilterProvider.notifier).setFilter(value);
      },
      selectedColor: AppColors.primaryCrimson,
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

  // --- TAB 2: BOLETAS DE PAGO ---
  Widget _buildBoletasPagoTab() {
    final boletasAsync = ref.watch(boletasPagoFiltradasProvider);

    return RefreshIndicator(
      color: AppColors.accentVibrant,
      backgroundColor: AppColors.carbonSurface,
      onRefresh: () async {
        ref.invalidate(boletasPagoProvider);
      },
      child: boletasAsync.when(
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
                    'Error al cargar boletas de pago: $err',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(boletasPagoProvider),
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
        data: (boletas) {
          if (boletas.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: AppColors.textSlateMuted),
                      SizedBox(height: 12),
                      Text(
                        'No se encontraron boletas de pago',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Los comprobantes arancelarios de Caja Campus se registrarán aquí.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
            itemCount: boletas.length,
            itemBuilder: (context, index) {
              return BoletaPagoCard(boleta: boletas[index]);
            },
          );
        },
      ),
    );
  }

  // --- TAB 3: INSCRIPCIONES Y PASES ---
  Widget _buildInscripcionesTab() {
    final inscripcionesAsync = ref.watch(boletasInscripcionFiltradasProvider);

    return RefreshIndicator(
      color: AppColors.accentVibrant,
      backgroundColor: AppColors.carbonSurface,
      onRefresh: () async {
        ref.invalidate(boletasInscripcionProvider);
      },
      child: inscripcionesAsync.when(
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
                    'Error al cargar membresías: $err',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.textSlateMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(boletasInscripcionProvider),
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
        data: (inscripciones) {
          if (inscripciones.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.badge_outlined,
                          size: 48, color: AppColors.textSlateMuted),
                      SizedBox(height: 12),
                      Text(
                        'No se encontraron boletas de inscripción',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Tus membresías activas aparecerán aquí una vez completado el arancel en Caja Campus.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSlateMuted),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
            itemCount: inscripciones.length,
            itemBuilder: (context, index) {
              return BoletaInscripcionCard(boleta: inscripciones[index]);
            },
          );
        },
      ),
    );
  }
}
