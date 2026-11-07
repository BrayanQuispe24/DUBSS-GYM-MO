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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(
              isAprobar ? '¿Aprobar Solicitud?' : '¿Rechazar Solicitud?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isAprobar
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
            ),
            content: Text(
              isAprobar
                  ? 'Se marcará la solicitud ${sol.numeroFormulario} como APROBADA para proceder con el cobro y matrícula del socio.'
                  : '¿Está seguro de marcar la solicitud ${sol.numeroFormulario} como RECHAZADA?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAprobar
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
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
            backgroundColor: isAprobar ? AppColors.success : AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleEmitirInscripcion(BoletaPagoModel pago) async {
    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text(
              'Emitir Inscripción & QR',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF003B70),
              ),
            ),
            content: Text(
              '¿Desea generar la Boleta de Inscripción y Credencial QR para el socio a partir del pago #${pago.numeroBoleta} por Bs. ${pago.monto.toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077D4),
                  foregroundColor: Colors.white,
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
            backgroundColor: AppColors.success,
          ),
        );
        _tabController.animateTo(2); // Ir al tab de inscripciones
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al emitir inscripción: $e'),
            backgroundColor: AppColors.danger,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Trámites & Pagos Recepción',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Actualizar',
            onPressed: _refrescarTodo,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Colors.white),
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
          indicatorColor: const Color(0xFFD97706),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
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
          child: CircularProgressIndicator(color: AppColors.navyBlue)),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text('Error al cargar solicitudes: $e',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: _refrescarTodo, child: const Text('Reintentar')),
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
          color: AppColors.navyBlue,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Barra de búsqueda y selector de filtros
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por socio, Nº formulario o disciplina...',
                  hintStyle:
                      const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_late_outlined,
                          size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'No se encontraron solicitudes con los filtros aplicados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
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
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _filtroEstado = value),
        selectedColor: const Color(0xFF003B70),
        backgroundColor: Colors.white,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF003B70)
                : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudCard(FormularioSolicitudModel sol) {
    final isPendiente = sol.isPendiente;
    final isAprobado = sol.isAprobado;

    Color badgeBg = const Color(0xFFFEF3C7);
    Color badgeText = const Color(0xFFB45309);
    if (isAprobado) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF15803D);
    } else if (sol.isRechazado) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFB91C1C);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: Color(0xFF0077D4),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
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
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                '${sol.disciplinaNombre} • ${sol.planNombre}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                  foregroundColor: const Color(0xFF003B70),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: Color(0xFF003B70)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
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
                  foregroundColor: const Color(0xFF0284C7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const Spacer(),
              if (isPendiente) ...[
                OutlinedButton(
                  onPressed: () =>
                      _handleCambiarEstadoSolicitud(sol, 'rechazada'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
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
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
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
          child: CircularProgressIndicator(color: AppColors.navyBlue)),
      error: (e, _) => Center(child: Text('Error al cargar pagos: $e')),
      data: (pagos) {
        if (pagos.isEmpty) {
          return const Center(
            child: Text('No hay boletas de pago registradas en el sistema.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refrescarTodo(),
          color: AppColors.navyBlue,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pagos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = pagos[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                            color: Color(0xFF003B70),
                          ),
                        ),
                        Text(
                          'Bs. ${p.monto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.concepto.isEmpty ? 'Pago de membresía gimnasio DUBSS' : p.concepto,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
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
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.metodoPago.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
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
                                backgroundColor: const Color(0xFF0077D4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
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
          child: CircularProgressIndicator(color: AppColors.navyBlue)),
      error: (e, _) => Center(child: Text('Error al cargar matrículas: $e')),
      data: (inscripciones) {
        if (inscripciones.isEmpty) {
          return const Center(
            child: Text('No hay matrículas de inscripción registradas.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _refrescarTodo(),
          color: AppColors.navyBlue,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inscripciones.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ins = inscripciones[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                            color: Color(0xFF003B70),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: ins.isActiva
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ins.isActiva ? 'VIGENTE' : 'VENCIDO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ins.isActiva
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Disciplina: ${ins.disciplina.isEmpty ? 'Gimnasio General' : ins.disciplina}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
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
                            backgroundColor: const Color(0xFF003B70),
                            foregroundColor: Colors.white,
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
