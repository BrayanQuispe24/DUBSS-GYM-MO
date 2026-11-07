import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../../data/models/admin_user_model.dart';
import '../widgets/user_form_modal.dart';

final userDetailFutureProvider =
    FutureProvider.family.autoDispose<AdminUserModel, int>((ref, userId) async {
  final ds = ref.watch(usersRemoteDataSourceProvider);
  return ds.getUserById(userId);
});

class UserDetailScreen extends ConsumerStatefulWidget {
  final int userId;

  const UserDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDetailFutureProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Expediente del Socio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () =>
                ref.invalidate(userDetailFutureProvider(widget.userId)),
          ),
          userAsync.when(
            data: (user) => IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () {
                UserFormModal.show(
                  context,
                  userToEdit: user,
                  onSuccess: () =>
                      ref.invalidate(userDetailFutureProvider(widget.userId)),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFFD97706),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF94A3B8),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Perfil'),
            Tab(text: 'Historial Médico'),
            Tab(text: 'Cuestionario'),
            Tab(text: 'Documentos'),
          ],
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.navyBlue),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text('Error al cargar expediente: $e',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(userDetailFutureProvider(widget.userId)),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (user) => TabBarView(
          controller: _tabCtrl,
          children: [
            _buildPerfilTab(user),
            _buildHistorialTab(user),
            _buildCuestionarioTab(user),
            _buildDocumentosTab(user),
          ],
        ),
      ),
    );
  }

  // 1. TAB PERFIL
  Widget _buildPerfilTab(AdminUserModel user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tarjeta principal con avatar y nombre
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF003B70).withValues(alpha: 0.1),
                child: Text(
                  user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF003B70),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.rolLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: user.isActivo
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.isActivo ? 'ACTIVO' : 'SUSPENDIDO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: user.isActivo
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB91C1C),
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
        const SizedBox(height: 16),

        // Datos Personales e Institucionales
        _buildInfoCard(
          title: 'Datos Personales & Universitarios',
          icon: Icons.badge_outlined,
          items: [
            _InfoRow('Carnet de Identidad (C.I.)', user.ci ?? 'No registrado'),
            _InfoRow('Registro Universitario (R.U.)',
                user.codigo ?? 'No registrado'),
            _InfoRow('Tipo de Usuario', user.tipoUsuario.toUpperCase()),
            _InfoRow('Celular / WhatsApp', user.celular ?? 'No registrado'),
            _InfoRow('Fecha de Alta', user.createdAt ?? 'Reciente'),
          ],
        ),
      ],
    );
  }

  // 2. TAB HISTORIAL MÉDICO
  Widget _buildHistorialTab(AdminUserModel user) {
    if (user.historiales.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 44, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'No existen fichas médicas o evaluaciones físicas registradas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: user.historiales.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final h = user.historiales[index] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Evaluación Médica',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF003B70),
                    ),
                  ),
                  Text(
                    h['fecha']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                h['observaciones']?.toString() ?? 'Sin observaciones anotadas',
                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. TAB CUESTIONARIO MÉDICO
  Widget _buildCuestionarioTab(AdminUserModel user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Cuestionario Oficial DUBSS-FR-03',
          icon: Icons.checklist_rounded,
          items: const [
            _InfoRow('Condición Médica Aprobada', 'Sí (Declaración oficial)'),
            _InfoRow('Enfermedades Cardiovasculares', 'Ninguna declarada'),
            _InfoRow('Afecciones Respiratorias / Asma', 'No presenta'),
            _InfoRow('Lesiones Musculares / Articulares', 'Sin antecedentes'),
            _InfoRow('Tratamiento Farmacológico', 'Ninguno'),
          ],
        ),
      ],
    );
  }

  // 4. TAB DOCUMENTOS DIGITALES
  Widget _buildDocumentosTab(AdminUserModel user) {
    if (user.documentos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_outlined, size: 44, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'El socio aún no ha anexado documentos digitales (matrícula, CI o certificado).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: user.documentos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doc = user.documentos[index] as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.red, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  doc['nombre']?.toString() ?? 'Documento Digital',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoRow> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF003B70), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          ...items.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    row.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    row.value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
