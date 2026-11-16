import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import '../../data/models/pricing_plan_model.dart';

class PricingPlansWidget extends StatelessWidget {
  final List<PricingPlanModel> plans;
  final void Function(PricingPlanModel plan)? onSelectPlan;

  const PricingPlansWidget({
    super.key,
    required this.plans,
    this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TARIFAS DE MEMBRESÍAS UAGRM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentVibrant,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Precios subvencionados para la comunidad universitaria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textWhite,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Subvención oficial de la Dirección Universitaria de Bienestar Social (D.U.B.S.).',
                style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 480,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Container(
                width: 280,
                decoration: BoxDecoration(
                  color: AppColors.carbonSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: plan.isPopular ? AppColors.accentVibrant : AppColors.borderSubtle,
                    width: plan.isPopular ? 1.5 : 1.0,
                  ),
                  boxShadow: plan.isPopular
                      ? [
                          BoxShadow(
                            color: AppColors.accentVibrant.withValues(alpha: 0.2),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plan.isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCrimson,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: AppColors.solarGold, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'MÁS POPULAR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              plan.target.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSlateMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textWhite,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  plan.price,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  plan.period,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSlateMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.successEmerald.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.successEmerald.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                plan.highlight,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.successLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            ...plan.features.take(4).map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 15,
                                    color: AppColors.successEmerald,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      f,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSlateLight,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: CrimsonButton(
                        onPressed: () => onSelectPlan?.call(plan),
                        label: plan.buttonText,
                        style: plan.isPopular
                            ? CrimsonButtonStyle.gradient
                            : CrimsonButtonStyle.glassPill,
                        height: 42,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
