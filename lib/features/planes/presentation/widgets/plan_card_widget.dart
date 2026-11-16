import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../../data/models/plan_model.dart';

class PlanCardWidget extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback? onSelect;
  final VoidCallback? onInscribirse;

  const PlanCardWidget({
    super.key,
    required this.plan,
    this.onSelect,
    this.onInscribirse,
  });

  @override
  Widget build(BuildContext context) {
    final isActivo = plan.isActivo;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Line Oficial
            Container(
              height: 3.0,
              color: isActivo ? AppColors.primaryCrimson : AppColors.borderSubtle,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Diamond Icon + Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Diamond icon inside soft square
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                        ),
                        child: const Icon(
                          Icons.diamond_outlined,
                          color: AppColors.solarGold,
                          size: 18,
                        ),
                      ),

                      // Status Badge (● ACTIVO)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActivo
                              ? AppColors.successEmerald.withValues(alpha: 0.15)
                              : AppColors.accentVibrant.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActivo ? AppColors.successEmerald : AppColors.accentVibrant,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActivo ? AppColors.successEmerald : AppColors.accentVibrant,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isActivo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isActivo ? AppColors.successLight : AppColors.accentVibrant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Plan Title
                  Text(
                    plan.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tarifa Chip
                  if (plan.tarifa != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.carbonSurfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_offer_outlined,
                            size: 11,
                            color: AppColors.solarGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'TARIFA: ${plan.tarifa!.nombre.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.solarGold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Description
                  Text(
                    plan.descripcion?.isNotEmpty == true
                        ? plan.descripcion!
                        : 'Sin especificaciones registradas para este plan institucional.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSlateLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Duration & Price Container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Clock & Duración
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.carbonSurface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                size: 15,
                                color: AppColors.solarGold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DURACIÓN',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSlateMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  '${plan.duracionDias} días',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right: Arancel
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'ARANCEL',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSlateMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              plan.tarifa != null ? 'Bs. ${plan.tarifa!.precio}' : 'Bs. 0.00',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mobile Action Button
                  SizedBox(
                    width: double.infinity,
                    child: CrimsonButton(
                      onPressed: onInscribirse ?? onSelect ?? () => _showPlanDetails(context),
                      label: 'Solicitar Membresía',
                      style: CrimsonButtonStyle.gradient,
                      height: 42,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlanDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.carbonSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
            left: BorderSide(color: AppColors.borderSubtle, width: 1.0),
            right: BorderSide(color: AppColors.borderSubtle, width: 1.0),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                    ),
                    child: const Icon(Icons.diamond_outlined, color: AppColors.solarGold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textWhite,
                          ),
                        ),
                        if (plan.tarifa != null)
                          Text(
                            'Tarifa: ${plan.tarifa!.nombre}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.solarGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Descripción del Plan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                plan.descripcion ?? 'Acceso a las áreas deportivas del Gimnasio UAGRM.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSlateLight, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.carbonSurfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'DURACIÓN',
                          style: TextStyle(fontSize: 10, color: AppColors.textSlateMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.duracionDias} DÍAS',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textWhite),
                        ),
                      ],
                    ),
                    Container(height: 24, width: 1, color: AppColors.borderSubtle),
                    Column(
                      children: [
                        const Text(
                          'TOTAL ARANCEL',
                          style: TextStyle(fontSize: 10, color: AppColors.textSlateMuted, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.tarifa != null ? 'Bs. ${plan.tarifa!.precio}' : 'Bs. 0.00',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CrimsonButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (onInscribirse != null) {
                      onInscribirse!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Solicitud para ${plan.nombre} iniciada. Pase por caja/trámites.'),
                          backgroundColor: AppColors.carbonSurfaceMuted,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                  label: 'Confirmar y Solicitar Boleta de Pago',
                  style: CrimsonButtonStyle.gradient,
                  height: 46,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
