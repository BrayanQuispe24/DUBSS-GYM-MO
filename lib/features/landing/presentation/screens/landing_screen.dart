import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:dubss_app/features/auth/presentation/providers/auth_notifier.dart';
import '../providers/landing_providers.dart';
import '../widgets/category_filter_bar.dart';
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.sports_gymnastics, color: AppColors.primaryRed),
                  SizedBox(width: 8),
                  Text(
                    'Preinscripción Universitaria',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Has seleccionado: $title ($price)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Requisitos DUBS:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                '• Boleta de inscripción actual o carnet universitario.\n• Certificado médico de aptitud física.\n• Fotocopia de Cédula de Identidad.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Solicitud iniciada para $title'),
                        backgroundColor: AppColors.navyBlue,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Continuar al Portal DUBS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UAGRM · D.U.B.S.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentGold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Gimnasio Universitario',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                    color: Colors.white,
                    onSelected: (val) {
                      if (val == 'portal') {
                        context.go('/client');
                      } else if (val == 'logout') {
                        ref.read(authNotifierProvider.notifier).logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sesión cerrada correctamente'),
                            backgroundColor: AppColors.navyBlue,
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
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              authState.user?.email ?? '',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'portal',
                        child: Row(
                          children: [
                            Icon(Icons.dashboard_outlined, size: 16, color: Color(0xFF0077D4)),
                            SizedBox(width: 8),
                            Text(
                              'Mi Portal Universitario',
                              style: TextStyle(
                                color: Color(0xFF0077D4),
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
                            Icon(Icons.logout, size: 16, color: AppColors.primaryRed),
                            SizedBox(width: 8),
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Chip(
                      backgroundColor: AppColors.primaryRed,
                      avatar: const Icon(Icons.account_circle, color: Colors.white, size: 16),
                      label: Text(
                        authState.user?.nombre ?? authState.user?.name.split(' ').first ?? 'Mi Cuenta',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                : TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login, size: 16, color: Colors.white),
                    label: const Text(
                      'Acceso',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
            // 1. Hero Institucional
            HeroSectionWidget(
              onExploreTap: () => _scrollToKey(_disciplinesKey),
              onMembershipsTap: () => _scrollToKey(_membershipsKey),
              onLoginTap: () => context.go('/login'),
            ),

            // 2. Filtros de Categorías
            Container(
              key: _disciplinesKey,
              child: const CategoryFilterBar(),
            ),

            const SizedBox(height: 18),

            // 3. Header de Disciplinas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disciplinas Deportivas UAGRM',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${disciplines.length} actividades disponibles en la Sede DUBS',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Carrusel de Disciplinas
            if (disciplines.isEmpty)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const Text(
                  'No hay disciplinas en esta categoría',
                  style: TextStyle(color: AppColors.textMuted),
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

            const SizedBox(height: 28),

            // 4. Inscribirte y Entrenar es Simple
            const HowItWorksWidget(),

            const SizedBox(height: 28),

            // 5. Precios y Membresías Subvencionadas
            Container(
              key: _membershipsKey,
              child: PricingPlansWidget(
                plans: plans,
                onSelectPlan: (plan) => _showEnrollmentDialog(plan.title, plan.price),
              ),
            ),

            const SizedBox(height: 32),

            // 6. Banner Final CTA
            CtaBannerWidget(
              onRegisterTap: () => _showEnrollmentDialog('Membresía Universitaria', 'Bs. 50 / mes'),
              onRequirementsTap: () {
                _showEnrollmentDialog('Requisitos de Inscripción', 'Gratuito');
              },
            ),

            const SizedBox(height: 36),

            // 7. Footer Institucional
            Container(
              width: double.infinity,
              color: AppColors.navyBlueDark,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  const Text(
                    'UNIVERSIDAD AUTÓNOMA GABRIEL RENÉ MORENO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dirección Universitaria de Bienestar Social (D.U.B.S.)\nSanta Cruz de la Sierra, Bolivia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Campus Universitario · Av. Busch',
                          style: TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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
