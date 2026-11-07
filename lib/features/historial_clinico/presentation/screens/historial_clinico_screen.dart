import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dubss_app/features/tramites/presentation/screens/visor_pdf_screen.dart';
import '../providers/historial_clinico_notifier.dart';
import '../providers/historial_clinico_state.dart';
import '../widgets/antecedentes_modal.dart';
import '../widgets/antecedentes_view_widget.dart';
import '../widgets/imc_gauge_indicator.dart';
import '../widgets/kpi_metric_card.dart';
import '../widgets/mediciones_timeline_widget.dart';
import '../widgets/nueva_medicion_modal.dart';
import '../widgets/pdf_historial_dubss_builder.dart';

class HistorialClinicoScreen extends ConsumerStatefulWidget {
  const HistorialClinicoScreen({super.key});

  @override
  ConsumerState<HistorialClinicoScreen> createState() => _HistorialClinicoScreenState();
}

class _HistorialClinicoScreenState extends ConsumerState<HistorialClinicoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _abrirFormularioDubssPdf(HistorialClinicoState state) {
    final historial = state.selectedHistorial;
    if (historial == null) return;

    VisorPdfScreen.open(
      context,
      title: 'Formulario DUBSS-FR-03',
      documentBuilder: () => PdfHistorialDubssBuilder.buildPdf(historial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historialClinicoNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        title: const Text(
          'Historial Clínico & Físico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (state.selectedHistorial != null)
            IconButton(
              tooltip: 'Ver Formulario DUBSS-FR-03 (PDF)',
              icon: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFF59E0B)),
              onPressed: () => _abrirFormularioDubssPdf(state),
            ),
          IconButton(
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref
                .read(historialClinicoNotifierProvider.notifier)
                .cargarHistoriales(forceRefresh: true),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          indicatorWeight: 3,
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Medición Actual'),
            Tab(text: 'Histórico Medidas'),
            Tab(text: 'Antecedentes'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
            )
          : state.hasError
              ? _buildErrorView(state.errorMessage)
              : _buildContentView(state),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Nueva Medición', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => NuevaMedicionModal.show(context),
            )
          : null,
    );
  }

  Widget _buildErrorView(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(
              error ?? 'Ocurrió un error al cargar el historial clínico',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
              ),
              onPressed: () => ref
                  .read(historialClinicoNotifierProvider.notifier)
                  .cargarHistoriales(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(HistorialClinicoState state) {
    final historial = state.selectedHistorial;
    if (historial == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_search_outlined, color: Colors.white38, size: 54),
              const SizedBox(height: 14),
              const Text(
                'No se encontró expediente clínico asignado.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Acércate a la administración del gimnasio para aperturar tu ficha oficial DUBSS.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                ),
                onPressed: () => ref
                    .read(historialClinicoNotifierProvider.notifier)
                    .cargarHistoriales(forceRefresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Volver a consultar'),
              ),
            ],
          ),
        ),
      );
    }

    final ultima = historial.ultimaMedicion;

    return TabBarView(
      controller: _tabController,
      children: [
        // Tab 1: Medición Actual & KPIs
        RefreshIndicator(
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () => ref
              .read(historialClinicoNotifierProvider.notifier)
              .cargarHistoriales(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info del socio
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFFF59E0B), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              historial.usuarioNombreCompleto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'RU: ${historial.usuarioRegistro.isNotEmpty ? historial.usuarioRegistro : "N/A"} | ${historial.facultadCarrera ?? "UAGRM"}',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            if (historial.grupoSanguineo != null && historial.grupoSanguineo!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.bloodtype, color: Color(0xFFEF4444), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Grupo: ${historial.grupoSanguineo}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (ultima == null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.monitor_weight_outlined, color: Colors.white.withAlpha(50), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'No hay mediciones físicas registradas.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Registra tu primera medición física para ver tus índices de composición corporal.',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => NuevaMedicionModal.show(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Registrar Medición', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Grid de KPIs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Última Evaluación Física',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatDate(ultima.fechaRegistro),
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      KpiMetricCard(
                        label: 'PESO',
                        value: ultima.peso != null ? '${ultima.peso}' : '--',
                        unit: 'kg',
                        icon: Icons.scale_rounded,
                        accentColor: const Color(0xFF3B82F6),
                        deltaText: historial.deltaPeso != null
                            ? '${historial.deltaPeso! > 0 ? "+" : ""}${historial.deltaPeso} kg'
                            : null,
                        isDeltaPositive: historial.deltaPeso != null ? historial.deltaPeso! <= 0 : null,
                      ),
                      KpiMetricCard(
                        label: 'ALTURA',
                        value: ultima.altura != null ? '${ultima.altura}' : '--',
                        unit: 'cm',
                        icon: Icons.height_rounded,
                        accentColor: const Color(0xFF10B981),
                      ),
                      KpiMetricCard(
                        label: 'GRASA CORPORAL',
                        value: ultima.porcentajeGrasa != null ? '${ultima.porcentajeGrasa}' : '--',
                        unit: '%',
                        icon: Icons.donut_large_rounded,
                        accentColor: const Color(0xFFF59E0B),
                        deltaText: historial.deltaGrasa != null
                            ? '${historial.deltaGrasa! > 0 ? "+" : ""}${historial.deltaGrasa}%'
                            : null,
                        isDeltaPositive: historial.deltaGrasa != null ? historial.deltaGrasa! <= 0 : null,
                      ),
                      KpiMetricCard(
                        label: 'MASA MUSCULAR',
                        value: ultima.masaMuscular != null ? '${ultima.masaMuscular}' : '--',
                        unit: '%',
                        icon: Icons.fitness_center_rounded,
                        accentColor: const Color(0xFF8B5CF6),
                        deltaText: historial.deltaMusculo != null
                            ? '${historial.deltaMusculo! > 0 ? "+" : ""}${historial.deltaMusculo}%'
                            : null,
                        isDeltaPositive: historial.deltaMusculo != null ? historial.deltaMusculo! >= 0 : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Semáforo Gauge de IMC
                  ImcGaugeIndicator(
                    imc: ultima.imcCalculado,
                    clasificacion: ultima.clasificacionImc,
                    statusColor: Color(ultima.colorImcHex),
                  ),
                  const SizedBox(height: 16),

                  // Datos Adicionales (Presión)
                  if (ultima.presion != null && ultima.presion!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.monitor_heart_outlined, color: Color(0xFFEF4444), size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Presión Arterial Registrada',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          Text(
                            '${ultima.presion} mmHg',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Tab 2: Histórico de Mediciones
        RefreshIndicator(
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () => ref
              .read(historialClinicoNotifierProvider.notifier)
              .cargarHistoriales(forceRefresh: true),
          child: MedicionesTimelineWidget(
            mediciones: historial.detalles,
            onNuevaMedicion: () => NuevaMedicionModal.show(context),
          ),
        ),

        // Tab 3: Cuestionario de Antecedentes Médicos
        RefreshIndicator(
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () => ref
              .read(historialClinicoNotifierProvider.notifier)
              .cargarHistoriales(forceRefresh: true),
          child: AntecedentesViewWidget(
            antecedente: historial.ultimoAntecedente,
            onEdit: () => AntecedentesModal.show(
              context,
              antecedenteInicial: historial.ultimoAntecedente,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }
}
