import 'package:flutter/material.dart';

class ImcGaugeIndicator extends StatelessWidget {
  final double imc;
  final String clasificacion;
  final Color statusColor;

  const ImcGaugeIndicator({
    super.key,
    required this.imc,
    required this.clasificacion,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    // Normalizar valor entre 15 y 40 para la posición relativa de la aguja (0.0 a 1.0)
    final clampedImc = imc.clamp(15.0, 40.0);
    final progress = (clampedImc - 15.0) / (40.0 - 15.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.speed_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Índice de Masa Corporal (IMC)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withAlpha(80)),
                ),
                child: Text(
                  clasificacion,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de rango continua
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Barra segmentada degradada
                      Container(
                        height: 10,
                        width: totalWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6), // Bajo peso (<18.5)
                              Color(0xFF10B981), // Normal (18.5 - 24.9)
                              Color(0xFFF59E0B), // Sobrepeso (25 - 29.9)
                              Color(0xFFEF4444), // Obesidad (>=30)
                            ],
                            stops: [0.15, 0.40, 0.70, 1.0],
                          ),
                        ),
                      ),
                      // Indicador de aguja / puntero
                      Positioned(
                        left: (progress * totalWidth).clamp(0.0, totalWidth - 14),
                        top: -4,
                        child: Container(
                          width: 14,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(100),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('< 18.5 (Bajo)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      Text('18.5 - 24.9 (Normal)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      Text('25 - 29.9 (Sobrepeso)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                      Text('> 30 (Obesidad)', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
