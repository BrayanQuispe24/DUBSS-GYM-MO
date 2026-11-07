import 'package:flutter/material.dart';
import '../../data/models/evaluacion_antropometrica_model.dart';

class EvolucionTimelineWidget extends StatelessWidget {
  final List<EvaluacionAntropometricaModel> evaluaciones;

  const EvolucionTimelineWidget({
    super.key,
    required this.evaluaciones,
  });

  @override
  Widget build(BuildContext context) {
    if (evaluaciones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.timeline_rounded, color: Colors.white.withAlpha(50), size: 48),
              const SizedBox(height: 12),
              const Text(
                'Sin registros previos para mostrar evolución',
                style: TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evolución Histórica',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Comparativa cronológica de tus evaluaciones físicas',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: evaluaciones.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = evaluaciones[index];
            final isFirst = index == 0;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFirst
                      ? const Color(0xFFF59E0B).withAlpha(100)
                      : Colors.white.withAlpha(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isFirst ? Icons.verified_rounded : Icons.history_rounded,
                            color: isFirst ? const Color(0xFFF59E0B) : Colors.white60,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(item.fechaEvaluacion),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isFirst)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ÚLTIMA EVALUACIÓN',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniMetric('Peso', '${item.pesoKg} kg'),
                      _buildMiniMetric('IMC', item.imcCalculado.toStringAsFixed(1)),
                      _buildMiniMetric('Grasa', '${item.porcentajeGrasa ?? "--"} %'),
                      _buildMiniMetric('Músculo', '${item.porcentajeMusculo ?? "--"} %'),
                    ],
                  ),
                  if (item.observaciones != null && item.observaciones!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.observaciones!,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
