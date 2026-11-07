import 'package:flutter/material.dart';
import '../../data/models/detalle_historial_model.dart';

class MedicionesTimelineWidget extends StatelessWidget {
  final List<DetalleHistorialModel> mediciones;
  final VoidCallback onNuevaMedicion;

  const MedicionesTimelineWidget({
    super.key,
    required this.mediciones,
    required this.onNuevaMedicion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historial de Mediciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mediciones.length} registro(s) encontrado(s)',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onNuevaMedicion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Medir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (mediciones.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Column(
                children: [
                  Icon(Icons.scale_rounded, color: Colors.white.withAlpha(60), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay mediciones físicas registradas aún.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Presiona el botón "Medir" para ingresar tus primeros datos.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mediciones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = mediciones[index];
                final isFirst = index == 0;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isFirst ? const Color(0xFFF59E0B).withAlpha(120) : Colors.white.withAlpha(20),
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
                                isFirst ? Icons.stars_rounded : Icons.calendar_today_rounded,
                                color: isFirst ? const Color(0xFFF59E0B) : Colors.white60,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(item.fechaRegistro),
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
                                'MÁS RECIENTE',
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
                          _buildMetricItem('Peso', item.peso != null ? '${item.peso} kg' : '--'),
                          _buildMetricItem('Altura', item.altura != null ? '${item.altura} cm' : '--'),
                          _buildMetricItem('IMC', item.imcCalculado > 0 ? item.imcCalculado.toString() : '--'),
                          _buildMetricItem('Grasa', item.porcentajeGrasa != null ? '${item.porcentajeGrasa}%' : '--'),
                          _buildMetricItem('Músculo', item.masaMuscular != null ? '${item.masaMuscular}%' : '--'),
                        ],
                      ),
                      if (item.presion != null && item.presion!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.favorite_outline, color: Color(0xFFEF4444), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Presión arterial: ${item.presion}',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
