import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../tramites/presentation/screens/escaner_qr_screen.dart';
import '../providers/receptionist_dashboard_provider.dart';

class ReceptionistDashboardScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onSelectTab;

  const ReceptionistDashboardScreen({
    super.key,
    this.onSelectTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final kpisAsync = ref.watch(receptionistDashboardProvider);

    final now = DateTime.now();
    final List<String> meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final fechaHoyStr = '${now.day} de ${meses[now.month]} de ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(receptionistDashboardProvider);
          },
          color: AppColors.navyBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER DE BIENVENIDA INSTITUCIONAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF003B70), Color(0xFF002244)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003B70).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PANEL DE RECEPCIÓN DUBSS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          fechaHoyStr,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hola, ${user?.nombreCompleto ?? 'Recepcionista'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Control operativo y atención de atletas universitarios UAGRM',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // BANNER DE ACCIÓN RÁPIDA: GARITA Y ESCÁNER QR
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primaryRed,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Garita & Escaneo In Situ',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Marcación rápida de entrada o salida',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => EscanerQRScreen.open(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Escanear',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // SECCIÓN: KPIS DEL DÍA
              const Text(
                'Métricas del Día',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              kpisAsync.when(
                data: (kpis) => Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Aforo Actual',
                        value: '${kpis.aforoActual}',
                        subtitle: 'Socios en sala',
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFDCFCE7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Solicitudes',
                        value: '${kpis.solicitudesPendientes}',
                        subtitle: 'Pendientes',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildKpiCard(
                        title: 'Cobros Hoy',
                        value: 'Bs. ${kpis.totalRecaudadoHoy.toStringAsFixed(0)}',
                        subtitle: '${kpis.pagosHoy} boletas',
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF0077D4),
                        bgColor: const Color(0xFFE0F2FE),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.navyBlue),
                  ),
                ),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 22),

              // SECCIÓN: LOS 7 MÓDULOS DE RECEPCIÓN
              const Text(
                'Módulos de Atención',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _buildModuleCard(
                    title: 'Garita de Acceso',
                    description: 'Marcaciones en vivo y aforo',
                    icon: Icons.door_sliding_outlined,
                    color: const Color(0xFF003B70),
                    onTap: () {
                      if (onSelectTab != null) {
                        onSelectTab!(1); // Tab Garita
                      } else {
                        context.push('/receptionist/garita');
                      }
                    },
                  ),
                  _buildModuleCard(
                    title: 'Gestión de Usuarios',
                    description: 'Atletas, docentes y expedientes',
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => context.push('/receptionist/usuarios'),
                  ),
                  _buildModuleCard(
                    title: 'Trámites y Pagos',
                    description: 'Aprobaciones y boletas',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      if (onSelectTab != null) {
                        onSelectTab!(2); // Tab Trámites
                      } else {
                        context.push('/receptionist/tramites');
                      }
                    },
                  ),
                  _buildModuleCard(
                    title: 'Planes y Tarifas',
                    description: 'Membresías y aranceles Bs.',
                    icon: Icons.card_membership_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => context.push('/receptionist/planes'),
                  ),
                  _buildModuleCard(
                    title: 'Disciplinas y Horas',
                    description: 'Aforos, turnos y cupos',
                    icon: Icons.sports_gymnastics_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/receptionist/disciplinas'),
                  ),
                  _buildModuleCard(
                    title: 'Ambientes y Salas',
                    description: 'Pesas, Cardio, Boxeo',
                    icon: Icons.meeting_room_outlined,
                    color: const Color(0xFF0D9488),
                    onTap: () => context.push('/receptionist/ambientes'),
                  ),
                  _buildModuleCard(
                    title: 'Inventario Equipos',
                    description: 'Maquinaria y marcas',
                    icon: Icons.fitness_center_rounded,
                    color: const Color(0xFF990000),
                    onTap: () => context.push('/receptionist/equipos'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
