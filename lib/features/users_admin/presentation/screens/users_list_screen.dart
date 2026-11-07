import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/admin_user_model.dart';
import '../providers/users_provider.dart';
import '../widgets/user_form_modal.dart';
import 'user_detail_screen.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleToggleStatus(AdminUserModel user) async {
    final success = await ref
        .read(usersAdminNotifierProvider.notifier)
        .toggleUserStatus(user.id, user.estado);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActivo
                ? 'Usuario ${user.nombreCompleto} SUSPENDIDO'
                : 'Usuario ${user.nombreCompleto} ACTIVADO',
          ),
          backgroundColor: user.isActivo ? AppColors.danger : AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete(AdminUserModel user) async {
    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text('¿Eliminar Usuario?'),
            content: Text(
              '¿Está seguro de eliminar definitivamente a ${user.nombreCompleto}? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmar) return;

    final success = await ref
        .read(usersAdminNotifierProvider.notifier)
        .deleteUser(user.id);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersAdminNotifierProvider);
    final usuarios = state.filteredUsuarios;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.navyBlueDark,
        elevation: 0,
        title: const Text(
          'Gestión de Usuarios & Socios',
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
                ref.read(usersAdminNotifierProvider.notifier).cargarUsuarios(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => UserFormModal.show(context),
        backgroundColor: const Color(0xFF003B70),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
        label: const Text(
          'Nuevo Usuario',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(usersAdminNotifierProvider.notifier).cargarUsuarios(),
        color: AppColors.navyBlue,
        child: Column(
          children: [
            // BARRA DE BÚSQUEDA Y FILTROS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => ref
                        .read(usersAdminNotifierProvider.notifier)
                        .setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, CI, RU o correo...',
                      hintStyle: const TextStyle(
                          fontSize: 12.5, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: Color(0xFF64748B)),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref
                                    .read(usersAdminNotifierProvider.notifier)
                                    .setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filtros por Rol
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRoleChip('Todos', 'todos', state.rolFilter),
                        _buildRoleChip(
                            'Clientes', 'cliente', state.rolFilter),
                        _buildRoleChip(
                            'Instructores', 'instructor', state.rolFilter),
                        _buildRoleChip('Recepcionistas', 'recepcionista',
                            state.rolFilter),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // LISTA DE USUARIOS
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.navyBlue),
                    )
                  : usuarios.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron usuarios',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: usuarios.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final u = usuarios[index];
                            return _buildUserCard(u);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String value, String currentVal) {
    final bool isSelected = currentVal == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        selected: isSelected,
        onSelected: (_) => ref
            .read(usersAdminNotifierProvider.notifier)
            .setRolFilter(value),
        selectedColor: const Color(0xFF003B70),
        backgroundColor: const Color(0xFFF1F5F9),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildUserCard(AdminUserModel u) {
    final bool isActivo = u.isActivo;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActivo ? const Color(0xFFE2E8F0) : const Color(0xFFFCA5A5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar con iniciales
          CircleAvatar(
            radius: 22,
            backgroundColor: isActivo
                ? const Color(0xFF003B70).withValues(alpha: 0.1)
                : const Color(0xFFFEE2E2),
            child: Text(
              u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isActivo ? const Color(0xFF003B70) : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Datos del usuario
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => UserDetailScreen(userId: u.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          u.nombreCompleto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          u.rolLabel,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077D4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    u.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (u.ci != null && u.ci!.isNotEmpty)
                        Text(
                          'CI: ${u.ci}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      if (u.codigo != null && u.codigo!.isNotEmpty) ...[
                        const Text(' • ',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFFCBD5E1))),
                        Text(
                          'RU: ${u.codigo}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Switch de estado Activo / Suspendido
          Column(
            children: [
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: isActivo,
                  activeTrackColor: const Color(0xFF16A34A),
                  onChanged: (_) => _handleToggleStatus(u),
                ),
              ),
              Text(
                isActivo ? 'ACTIVO' : 'BLOQUEADO',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isActivo
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),

          // Menú de opciones
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            onSelected: (val) {
              if (val == 'detail') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => UserDetailScreen(userId: u.id),
                  ),
                );
              } else if (val == 'edit') {
                UserFormModal.show(context, userToEdit: u);
              } else if (val == 'delete') {
                _handleDelete(u);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'detail',
                child: Row(
                  children: [
                    Icon(Icons.badge_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Ver Expediente'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Editar Datos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
