import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MacrosSummaryWidget extends StatelessWidget {
  final int calorias;
  final double proteinasG;
  final double carbohidratosG;
  final double grasasG;
  final double? hidratacionLitros;

  const MacrosSummaryWidget({
    super.key,
    required this.calorias,
    required this.proteinasG,
    required this.carbohidratosG,
    required this.grasasG,
    this.hidratacionLitros,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: AppColors.solarGold, size: 16),
                    SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'BALANCE NUTRICIONAL DIARIO',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSlateLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hidratacionLitros != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.carbonSurfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop, size: 11, color: AppColors.solarAmber),
                      const SizedBox(width: 3),
                      Text(
                        '${hidratacionLitros!.toStringAsFixed(1)} L/día',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solarAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Calorías
              Expanded(
                flex: 11,
                child: _buildMetricTile(
                  label: 'Calorías',
                  value: '$calorias',
                  unit: 'kcal',
                  color: AppColors.accentVibrant,
                  bgColor: AppColors.carbonSurfaceMuted,
                  icon: Icons.local_fire_department,
                ),
              ),
              const SizedBox(width: 6),
              // Proteína
              Expanded(
                flex: 10,
                child: _buildMetricTile(
                  label: 'Proteína',
                  value: proteinasG.toStringAsFixed(0),
                  unit: 'g',
                  color: AppColors.primaryCrimson,
                  bgColor: AppColors.carbonSurfaceMuted,
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 6),
              // Carbohidratos
              Expanded(
                flex: 10,
                child: _buildMetricTile(
                  label: 'Carbos',
                  value: carbohidratosG.toStringAsFixed(0),
                  unit: 'g',
                  color: AppColors.solarGold,
                  bgColor: AppColors.carbonSurfaceMuted,
                  icon: Icons.grain,
                ),
              ),
              const SizedBox(width: 6),
              // Grasas
              Expanded(
                flex: 9,
                child: _buildMetricTile(
                  label: 'Grasas',
                  value: grasasG.toStringAsFixed(0),
                  unit: 'g',
                  color: AppColors.successLight,
                  bgColor: AppColors.carbonSurfaceMuted,
                  icon: Icons.opacity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 11, color: color),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSlateMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
