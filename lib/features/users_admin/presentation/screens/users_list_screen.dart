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
          backgroundColor: user.isActivo ? AppColors.accentVibrant : AppColors.successEmerald,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete(AdminUserModel user) async {
    final bool confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.carbonSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: AppColors.borderSubtle),
            ),
            title: const Text(
              '¿Eliminar Usuario?',
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Está seguro de eliminar definitivamente a ${user.nombreCompleto}? Esta acción no se puede deshacer.',
              style: const TextStyle(color: AppColors.textSlateLight, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textSlateMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentVibrant,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
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
          backgroundColor: AppColors.accentVibrant,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersAdminNotifierProvider);
    final usuarios = state.filteredUsuarios;

    return Scaffold(
      backgroundColor: AppColors.obsidianBase,
      appBar: AppBar(
        backgroundColor: AppColors.obsidianBase,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Gestión de Usuarios & Socios',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSlateLight),
            onPressed: () =>
                ref.read(usersAdminNotifierProvider.notifier).cargarUsuarios(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => UserFormModal.show(context),
        backgroundColor: AppColors.primaryCrimson,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.accentVibrant, width: 1.0),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
        label: const Text(
          'Nuevo Usuario',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(usersAdminNotifierProvider.notifier).cargarUsuarios(),
        color: AppColors.accentVibrant,
        backgroundColor: AppColors.carbonSurface,
        child: Column(
          children: [
            // BARRA DE BÚSQUEDA Y FILTROS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.carbonSurface,
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (val) => ref
                        .read(usersAdminNotifierProvider.notifier)
                        .setSearchQuery(val),
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, CI, RU o correo...',
                      hintStyle: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSlateMuted),
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: AppColors.textSlateMuted),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: AppColors.textSlateMuted),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref
                                    .read(usersAdminNotifierProvider.notifier)
                                    .setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.carbonSurfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: AppColors.accentVibrant),
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

            // LISTA DE USUARIOS
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.accentVibrant),
                    )
                  : usuarios.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron usuarios',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSlateMuted,
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
          color: isSelected ? Colors.white : AppColors.textSlateLight,
        ),
        selected: isSelected,
        onSelected: (_) => ref
            .read(usersAdminNotifierProvider.notifier)
            .setRolFilter(value),
        selectedColor: AppColors.primaryCrimson,
        backgroundColor: AppColors.carbonSurfaceMuted,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isSelected ? AppColors.accentVibrant : AppColors.borderSubtle,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(AdminUserModel u) {
    final bool isActivo = u.isActivo;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.carbonSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActivo ? AppColors.borderSubtle : AppColors.accentVibrant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar con iniciales
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActivo
                  ? AppColors.primaryCrimson.withValues(alpha: 0.2)
                  : AppColors.accentVibrant.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActivo ? AppColors.accentVibrant : AppColors.accentVibrant,
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isActivo ? AppColors.solarGold : AppColors.accentVibrant,
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
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.carbonSurfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          u.rolLabel,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.solarGold,
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
                      color: AppColors.textSlateLight,
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
                            color: AppColors.textSlateMuted,
                          ),
                        ),
                      if (u.codigo != null && u.codigo!.isNotEmpty) ...[
                        const Text(' • ',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.borderSubtle)),
                        Text(
                          'RU: ${u.codigo}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSlateMuted,
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
                  activeTrackColor: AppColors.successEmerald,
                  inactiveTrackColor: AppColors.carbonSurfaceMuted,
                  activeColor: Colors.white,
                  onChanged: (_) => _handleToggleStatus(u),
                ),
              ),
              Text(
                isActivo ? 'ACTIVO' : 'BLOQUEADO',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isActivo
                      ? AppColors.successEmerald
                      : AppColors.accentVibrant,
                ),
              ),
            ],
          ),

          // Menú de opciones
          Theme(
            data: Theme.of(context).copyWith(
              cardColor: AppColors.carbonSurface,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSlateMuted),
              color: AppColors.carbonSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: AppColors.borderSubtle),
              ),
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
                      Icon(Icons.badge_outlined, size: 18, color: AppColors.textSlateLight),
                      SizedBox(width: 8),
                      Text('Ver Expediente', style: TextStyle(color: AppColors.textWhite, fontSize: 12.5)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: AppColors.solarGold),
                      SizedBox(width: 8),
                      Text('Editar Datos', style: TextStyle(color: AppColors.textWhite, fontSize: 12.5)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.accentVibrant),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: AppColors.accentVibrant, fontSize: 12.5)),
                    ],
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
