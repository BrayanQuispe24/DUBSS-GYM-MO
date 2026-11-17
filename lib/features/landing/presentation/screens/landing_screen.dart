import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crimson_button.dart';
import 'package:dubss_app/features/auth/presentation/providers/auth_notifier.dart';
import '../providers/landing_providers.dart';
import '../widgets/cta_banner_widget.dart';
import '../widgets/discipline_card_widget.dart';
import '../widgets/hero_section_widget.dart';
import '../widgets/how_it_works_widget.dart';
import '../widgets/pricing_plans_widget.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _disciplinesKey = GlobalKey();
  final GlobalKey _membershipsKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showEnrollmentDialog(String title, String price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.carbonSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
              top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
              left: BorderSide(color: AppColors.borderSubtle, width: 1.0),
              right: BorderSide(color: AppColors.borderSubtle, width: 1.0),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCrimson.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.accentVibrant, width: 0.8),
                    ),
                    child: const Icon(Icons.sports_gymnastics, color: AppColors.accentVibrant, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Preinscripción Universitaria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Has seleccionado: $title ($price)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSlateLight,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Requisitos DUBS:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '• Boleta de inscripción actual o carnet universitario.\n• Certificado médico de aptitud física.\n• Fotocopia de Cédula de Identidad.',
                style: TextStyle(fontSize: 12, color: AppColors.textSlateMuted, height: 1.5),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: CrimsonButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Solicitud iniciada para $title'),
                        backgroundColor: AppColors.carbonSurfaceMuted,
                      ),
                    );
                  },
                  label: 'Continuar al Portal DUBS',
                  style: CrimsonButtonStyle.gradient,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disciplines = ref.watch(disciplinesProvider);
    final plans = ref.watch(pricingPlansProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        titleSpacing: 16,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryCrimson,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.accentVibrant, width: 1.0),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'D.U.B.S. · UAGRM',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textWhite,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'CENTRO DEPORTIVO OFICIAL',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.solarGold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: authState.isAuthenticated
                ? PopupMenuButton<String>(
                    color: AppColors.carbonSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
                    ),
                    onSelected: (val) {
                      if (val == 'portal') {
                        final isStaff = ref.read(authNotifierProvider).user?.isStaff ?? false;
                        if (isStaff) {
                          context.go('/receptionist');
                        } else {
                          context.go('/client');
                        }
                      } else if (val == 'logout') {
                        ref.read(authNotifierProvider.notifier).logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesión cerrada correctamente'),
                            backgroundColor: AppColors.carbonSurfaceMuted,
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.user?.name ?? 'Usuario UAGRM',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textWhite,
                              ),
                            ),
                            Text(
                              authState.user?.email ?? '',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSlateMuted),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'portal',
                        child: Row(
                          children: [
                            Icon(Icons.dashboard_outlined, size: 16, color: AppColors.accentVibrant),
                            SizedBox(width: 8),
                            Text(
                              'Mi Portal Universitario',
                              style: TextStyle(
                                color: AppColors.accentVibrant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 16, color: AppColors.accentVibrant),
                            SizedBox(width: 8),
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: AppColors.accentVibrant, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCrimson,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accentVibrant, width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_circle, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            authState.user?.nombre ?? authState.user?.name.split(' ').first ?? 'Mi Cuenta',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login_rounded, size: 14, color: AppColors.solarGold),
                    label: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Institucional Minimalista y Aireado
            HeroSectionWidget(
              onExploreTap: () => _scrollToKey(_disciplinesKey),
              onMembershipsTap: () => _scrollToKey(_membershipsKey),
              onLoginTap: () => context.go('/login'),
            ),

            const SizedBox(height: 28),

            // 2. Encabezado Limpio de Disciplinas
            Padding(
              key: _disciplinesKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 18,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCrimson,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Flexible(
                          child: Text(
                            'Disciplinas Deportivas',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textWhite,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.carbonSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      '${disciplines.length} Actividades',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.solarGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Carrusel de Disciplinas (Directo y sin filtros pesados)
            if (disciplines.isEmpty)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const Text(
                  'No hay disciplinas en esta categoría',
                  style: TextStyle(color: AppColors.textSlateMuted),
                ),
              )
            else
              SizedBox(
                height: 305,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: disciplines.length,
                  itemBuilder: (context, index) {
                    final item = disciplines[index];
                    return DisciplineCardWidget(
                      discipline: item,
                      onSelect: () => _showEnrollmentDialog(item.title, item.studentPrice),
                    );
                  },
                ),
              ),

            const SizedBox(height: 32),

            // 4. Inscribirte y Entrenar es Simple
            const HowItWorksWidget(),

            const SizedBox(height: 32),

            // 5. Precios y Membresías Subvencionadas
            Container(
              key: _membershipsKey,
              child: PricingPlansWidget(
                plans: plans,
                onSelectPlan: (plan) => _showEnrollmentDialog(plan.title, plan.price),
              ),
            ),

            const SizedBox(height: 36),

            // 6. Banner Final CTA
            CtaBannerWidget(
              onRegisterTap: () => _showEnrollmentDialog('Membresía Universitaria', 'Bs. 50 / mes'),
              onRequirementsTap: () {
                _showEnrollmentDialog('Requisitos de Inscripción', 'Gratuito');
              },
            ),

            const SizedBox(height: 40),

            // 7. Footer Institucional
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.carbonSurfaceMuted,
                border: Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                children: [
                  const Text(
                    'UNIVERSIDAD AUTÓNOMA GABRIEL RENÉ MORENO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Dirección Universitaria de Bienestar Social (D.U.B.S.)\nSanta Cruz de la Sierra, Bolivia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSlateMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.carbonSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                        ),
                        child: const Text(
                          'Campus Universitario · Av. Busch',
                          style: TextStyle(
                            color: AppColors.solarGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
