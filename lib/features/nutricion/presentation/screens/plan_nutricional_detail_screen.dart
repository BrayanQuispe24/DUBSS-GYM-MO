import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/plan_alimentacion_model.dart';
import '../providers/nutricion_provider.dart';
import '../widgets/comida_detail_card.dart';
import '../widgets/macros_summary_widget.dart';

class PlanNutricionalDetailScreen extends ConsumerWidget {
  final int planId;
  final PlanAlimentacionModel? planPreloaded;

  const PlanNutricionalDetailScreen({
    super.key,
    required this.planId,
    this.planPreloaded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Si viene preloaded o se encuentra en el plan seleccionado
    final planSeleccionado = ref.watch(planNutricionalSeleccionadoProvider);
    final plan = planPreloaded ?? (planSeleccionado?.id == planId ? planSeleccionado : null);

    if (plan == null) {
      // Si no está en memoria, buscar en la lista general de planes
      final planesAsync = ref.watch(planesAlimentacionProvider);
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Detalle del Plan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        body: planesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0077D4)),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar el plan: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ),
          data: (planes) {
            final found = planes.where((p) => p.id == planId).firstOrNull;
            if (found == null) {
              return const Center(
                child: Text('Plan nutricional no encontrado.'),
              );
            }
            return _buildDetailContent(context, ref, found);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detalle del Plan Nutricional',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: _buildDetailContent(context, ref, plan),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    WidgetRef ref,
    PlanAlimentacionModel plan,
  ) {
    // Calcular suma de macros de los detalles si están disponibles
    double totalProt = 0;
    double totalCarb = 0;
    double totalGras = 0;
    double totalCal = 0;

    for (final d in plan.detalles) {
      if (d.calorias != null) totalCal += d.calorias!;
      if (d.proteinas != null) totalProt += d.proteinas!;
      if (d.carbohidratos != null) totalCarb += d.carbohidratos!;
      if (d.grasas != null) totalGras += d.grasas!;
    }

    if (totalCal == 0) totalCal = plan.totalCalorias;
    if (totalProt == 0) totalProt = plan.totalProteinas;
    if (totalCarb == 0) totalCarb = plan.totalCarbohidratos;
    if (totalGras == 0) totalGras = plan.totalGrasas;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Hero Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0077D4), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0077D4).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PLAN NUTRICIONAL OFICIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: plan.estado ? const Color(0xFF10B981) : Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan.estado ? 'ACTIVO' : 'HISTÓRICO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              if (plan.objetivo != null && plan.objetivo!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  plan.objetivo!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        plan.usuarioNombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (plan.fechaInicio != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          plan.fechaInicio!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Resumen de Estrategia Nutricional
        if (plan.observacion != null && plan.observacion!.trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF0077D4), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'ESTRATEGIA NUTRICIONAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0077D4),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.observacion!.trim(),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF1E3A8A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Macros Summary Widget
        if (totalCal > 0 || totalProt > 0) ...[
          MacrosSummaryWidget(
            calorias: totalCal.toInt(),
            proteinasG: totalProt,
            carbohidratosG: totalCarb,
            grasasG: totalGras,
            hidratacionLitros: plan.hidratacionLitros,
          ),
          const SizedBox(height: 18),
        ],

        // Lista de comidas prescritas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'COMIDAS & RECETAS PRESCRITAS',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF475569),
                letterSpacing: 0.6,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF0077D4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${plan.detalles.length} comidas',
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

        if (plan.detalles.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Este plan no tiene platos prescritos registrados.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          )
        else
          ...List.generate(plan.detalles.length, (idx) {
            final detalle = plan.detalles[idx];
            return ComidaDetailCard(
              index: idx,
              tipoComida: detalle.tipoComida ?? 'Comida ${idx + 1}',
              horarioSugerido: detalle.horarioSugeridoString ?? detalle.hora ?? '',
              platoNombre: detalle.alimento,
              calorias: (detalle.calorias ?? detalle.cantidad ?? 0).toInt(),
              proteinasG: detalle.proteinas ?? 0,
              carbohidratosG: detalle.carbohidratos ?? 0,
              grasasG: detalle.grasas ?? 0,
              ingredientes: detalle.ingredientesList,
              instruccionesPreparacion: detalle.preparacionString,
              sustitutosAccesibles: detalle.sustitutosList,
              initialExpanded: idx == 0,
            );
          }),
      ],
    );
  }
}
