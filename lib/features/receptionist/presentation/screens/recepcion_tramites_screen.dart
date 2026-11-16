import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tramites/data/datasources/tramites_remote_datasource.dart';
import '../../../tramites/data/models/boleta_inscripcion_model.dart';
import '../../../tramites/data/models/boleta_pago_model.dart';
import '../../../tramites/data/models/formulario_solicitud_model.dart';
import '../../../tramites/presentation/providers/tramites_provider.dart';
import '../../../tramites/presentation/screens/visor_pdf_screen.dart';
import '../../../tramites/presentation/widgets/documentos_solicitud_modal.dart';
import '../../../tramites/presentation/widgets/formulario_dubss_create_modal.dart';
import '../../../tramites/presentation/widgets/pdf_boleta_inscripcion_builder.dart';
import '../../../tramites/presentation/widgets/pdf_boleta_pago_builder.dart';
import '../../../tramites/presentation/widgets/pdf_formulario_dubss_builder.dart';

class RecepcionTramitesScreen extends ConsumerStatefulWidget {
  const RecepcionTramitesScreen({super.key});

  @override
  ConsumerState<RecepcionTramitesScreen> createState() =>
      _RecepcionTramitesScreenState();
}

class _RecepcionTramitesScreenState extends ConsumerState<RecepcionTramitesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _filtroEstado = 'todos'; // 'todos', 'pendiente', 'aprobada', 'rechazada'

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

  void _refrescarTodo() {
    ref.invalidate(formulariosSolicitudProvider);
    ref.invalidate(boletasPagoProvider);
    ref.invalidate(boletasInscripcionProvider);
  }

  Future<void> _handleCambiarEstadoSolicitud(
      FormularioSolicitudModel sol, String nuevoEstado) async {
    final isAprobar = nuevoEstado.toLowerCase().startsWith('apro');
    final estadoTexto = isAprobar ? 'APROBADA' : 'RECHAZADA';
    final backendEstado = isAprobar ? 'aprobado' : 'rechazado';

    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.carbonSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            title: Text(
              isAprobar ? '¿Aprobar Solicitud?' : '¿Rechazar Solicitud?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isAprobar ? AppColors.successEmerald : AppColors.accentVibrant,
              ),
            ),
            content: Text(
              isAprobar
                  ? 'Se marcará la solicitud ${sol.numeroFormulario} como APROBADA para proceder con el cobro y matrícula del socio.'
                  : '¿Está seguro de marcar la solicitud ${sol.numeroFormulario} como RECHAZADA?',
              style: const TextStyle(color: AppColors.textSlateLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSlateMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAprobar
                      ? AppColors.successEmerald
                      : AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(isAprobar ? 'Aprobar' : 'Rechazar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    try {
      final ds = ref.read(tramitesRemoteDataSourceProvider);
      await ds.updateEstadoSolicitud(sol.id, backendEstado);
      _refrescarTodo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitud ${sol.numeroFormulario} marcada como $estadoTexto',
            ),
            backgroundColor: isAprobar ? AppColors.carbonSurfaceMuted : AppColors.primaryCrimson,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: AppColors.primaryCrimson,
          ),
        );
      }
    }
  }

  Future<void> _handleEmitirInscripcion(BoletaPagoModel pago) async {
    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.carbonSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            title: const Text(
              'Emitir Inscripción & QR',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.solarGold,
              ),
            ),
            content: Text(
              '¿Desea generar la Boleta de Inscripción y Credencial QR para el socio a partir del pago #${pago.numeroBoleta} por Bs. ${pago.monto.toStringAsFixed(2)}?',
              style: const TextStyle(color: AppColors.textSlateLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSlateMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Generar Matrícula'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    try {
      final ds = ref.read(tramitesRemoteDataSourceProvider);
      await ds.emitirInscripcionDesdePago(
        pago.id,
        numeroComprobante: pago.numeroBoleta,
      );
      _refrescarTodo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Boleta de Inscripción y QR generados con éxito!'),
            backgroundColor: AppColors.carbonSurfaceMuted,
          ),
        );
        _tabController.animateTo(2); // Ir al tab de inscripciones
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al emitir inscripción: $e'),
            backgroundColor: AppColors.primaryCrimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(formulariosSolicitudProvider);
    final boletasAsync = ref.watch(boletasPagoProvider);
    final inscripcionesAsync = ref.watch(boletasInscripcionProvider);

    final solCount = solicitudesAsync.asData?.value.length ?? 0;
    final bolCount = boletasAsync.asData?.value.length ?? 0;
    final insCount = inscripcionesAsync.asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Trámites & Pagos Recepción',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textWhite),
            tooltip: 'Actualizar',
            onPressed: _refrescarTodo,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.accentVibrant),
            tooltip: 'Nueva Solicitud',
            onPressed: () async {
              final ok = await FormularioDubssCreateModal.show(context);
              if (ok == true) {
                _refrescarTodo();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryCrimson,
          indicatorWeight: 3,
          labelColor: AppColors.textWhite,
          unselectedLabelColor: AppColors.textSlateMuted,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('Solicitudes ($solCount)'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('Pagos ($bolCount)'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.badge_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('Matrículas ($insCount)'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSolicitudesTab(solicitudesAsync),
          _buildPagosTab(boletasAsync),
          _buildInscripcionesTab(inscripcionesAsync),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 1: SOLICITUDES GENERALES CON ACCIONES DE APROBAR / RECHAZAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildSolicitudesTab(
      AsyncValue<List<FormularioSolicitudModel>> solicitudesAsync) {
    return solicitudesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCrimson)),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.accentVibrant, size: 40),
              const SizedBox(height: 8),
              Text('Error al cargar solicitudes: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSlateLight)),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCrimson,
                  foregroundColor: Colors.white,
                ),
                onPressed: _refrescarTodo,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      data: (solicitudes) {
        final query = _searchController.text.toLowerCase().trim();
        final filtradas = solicitudes.where((s) {
          if (_filtroEstado != 'todos' &&
              s.estado.toLowerCase() != _filtroEstado) {
            return false;
          }
          if (query.isNotEmpty) {
            final num = s.numeroFormulario.toLowerCase();
            final nom = (s.usuarioNombre ?? '').toLowerCase();
            final disc = s.disciplinaNombre.toLowerCase();
            return num.contains(query) ||
                nom.contains(query) ||
                disc.contains(query);
          }
          return true;
        }).toList();

        return RefreshIndicator(
          onRefresh: () async => _refrescarTodo(),
          color: AppColors.primaryCrimson,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Barra de búsqueda y selector de filtros
              TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por socio, Nº formulario o disciplina...',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.textSlateMuted),
                  filled: true,
                  fillColor: AppColors.carbonSurface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
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
              const SizedBox(height: 10),

              // Chips de filtros de estado
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', 'todos'),
                    _buildFilterChip('Pendientes', 'pendiente'),
                    _buildFilterChip('Aprobadas', 'aprobada'),
                    _buildFilterChip('Rechazadas', 'rechazada'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (filtradas.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.assignment_late_outlined,
                          size: 44, color: AppColors.textSlateMuted),
                      SizedBox(height: 10),
                      Text(
                        'No se encontraron solicitudes con los filtros aplicados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSlateMuted,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...filtradas.map((sol) => _buildSolicitudCard(sol)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _filtroEstado == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSlateLight,
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _filtroEstado = value),
        selectedColor: AppColors.primaryCrimson,
        backgroundColor: AppColors.carbonSurface,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isSelected
                ? AppColors.accentVibrant
                : AppColors.borderSubtle,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudCard(FormularioSolicitudModel sol) {
    final isPendiente = sol.isPendiente;
    final isAprobado = sol.isAprobado;

    Color badgeBg = AppColors.solarAmber.withValues(alpha: 0.15);
    Color badgeText = AppColors.solarGold;
    if (isAprobado) {
      badgeBg = AppColors.successEmerald.withValues(alpha: 0.15);
      badgeText = AppColors.successLight;
    } else if (sol.isRechazado) {
      badgeBg = AppColors.primaryCrimson.withValues(alpha: 0.15);
      badgeText = AppColors.accentVibrant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sol.numeroFormulario,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.solarGold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeText.withValues(alpha: 0.4)),
                ),
                child: Text(
                  sol.estadoLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sol.usuarioNombre ?? 'Socio no especificado',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  size: 14, color: AppColors.accentVibrant),
              const SizedBox(width: 4),
              Text(
                '${sol.disciplinaNombre} • ${sol.planNombre}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSlateLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),

          // Botones de acción: Aprobar, Rechazar, Ver PDF
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  VisorPdfScreen.open(
                    context,
                    title: 'Formulario ${sol.numeroFormulario}',
                    documentBuilder: () =>
                        PdfFormularioDubssBuilder.buildPdf(sol),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 15),
                label: const Text(
                  'Ver PDF',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.borderSubtle),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                onPressed: () => DocumentosSolicitudModal.show(context, sol),
                icon: const Icon(Icons.folder_shared_outlined, size: 15),
                label: Text(
                  'Docs (${sol.documentosCount})',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.solarGold,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: AppColors.borderSubtle),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const Spacer(),
              if (isPendiente) ...[
                OutlinedButton(
                  onPressed: () =>
                      _handleCambiarEstadoSolicitud(sol, 'rechazada'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentVibrant,
                    side: const BorderSide(color: AppColors.primaryCrimson),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Rechazar',
                      style: TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: () =>
                      _handleCambiarEstadoSolicitud(sol, 'aprobada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: const Text('Aprobar',
                      style: TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 2: BOLETAS DE PAGO
  // ─────────────────────────────────────────────────────────────
  Widget _buildPagosTab(AsyncValue<List<BoletaPagoModel>> boletasAsync) {
    return boletasAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCrimson)),
      error: (e, _) => Center(child: Text('Error al cargar pagos: $e', style: const TextStyle(color: AppColors.textSlateLight))),
      data: (pagos) {
        if (pagos.isEmpty) {
          return const Center(
            child: Text('No hay boletas de pago registradas en el sistema.', style: TextStyle(color: AppColors.textSlateMuted)),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refrescarTodo(),
          color: AppColors.primaryCrimson,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pagos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = pagos[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.carbonSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Boleta #${p.numeroBoleta}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          'Bs. ${p.monto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.solarGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.concepto.isEmpty ? 'Pago de membresía gimnasio DUBSS' : p.concepto,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSlateLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.carbonSurfaceMuted,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            p.metodoPago.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSlateLight,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                VisorPdfScreen.open(
                                  context,
                                  title: 'Boleta de Pago #${p.numeroBoleta}',
                                  documentBuilder: () =>
                                      PdfBoletaPagoBuilder.buildPdf(p),
                                );
                              },
                              icon: const Icon(Icons.print_outlined, size: 13),
                              label: const Text(
                                'Recibo',
                                style: TextStyle(
                                    fontSize: 10.5, fontWeight: FontWeight.w700),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textWhite,
                                side: const BorderSide(color: AppColors.borderSubtle),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 5),
                            ElevatedButton.icon(
                              onPressed: () => _handleEmitirInscripcion(p),
                              icon: const Icon(Icons.qr_code_2_rounded, size: 14),
                              label: const Text(
                                'Matricular',
                                style: TextStyle(
                                    fontSize: 10.5, fontWeight: FontWeight.w800),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryCrimson,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 3: MATRÍCULAS / BOLETAS DE INSCRIPCIÓN Y QR
  // ─────────────────────────────────────────────────────────────
  Widget _buildInscripcionesTab(
      AsyncValue<List<BoletaInscripcionModel>> inscripcionesAsync) {
    return inscripcionesAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryCrimson)),
      error: (e, _) => Center(child: Text('Error al cargar matrículas: $e', style: const TextStyle(color: AppColors.textSlateLight))),
      data: (inscripciones) {
        if (inscripciones.isEmpty) {
          return const Center(
            child: Text('No hay matrículas de inscripción registradas.', style: TextStyle(color: AppColors.textSlateMuted)),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refrescarTodo(),
          color: AppColors.primaryCrimson,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inscripciones.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ins = inscripciones[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.carbonSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Matrícula #${ins.numeroBoleta}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: ins.isActiva
                                ? AppColors.successEmerald.withValues(alpha: 0.15)
                                : AppColors.primaryCrimson.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: ins.isActiva
                                  ? AppColors.successEmerald.withValues(alpha: 0.35)
                                  : AppColors.primaryCrimson.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            ins.isActiva ? 'VIGENTE' : 'VENCIDO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ins.isActiva
                                  ? AppColors.successLight
                                  : AppColors.accentVibrant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ins.usuarioNombre ?? 'Socio Universitario',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                    Text(
                      'Disciplina: ${ins.disciplina.isEmpty ? 'Gimnasio General' : ins.disciplina}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSlateLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            VisorPdfScreen.open(
                              context,
                              title: 'Credencial QR #${ins.numeroBoleta}',
                              documentBuilder: () =>
                                  PdfBoletaInscripcionBuilder.buildPdf(ins),
                            );
                          },
                          icon: const Icon(Icons.picture_as_pdf_outlined,
                              size: 15),
                          label: const Text(
                            'Pase Oficial & QR',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryCrimson,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
