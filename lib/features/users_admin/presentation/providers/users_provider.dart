import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../../data/models/admin_user_model.dart';

class UsersAdminState {
  final bool isLoading;
  final List<AdminUserModel> usuarios;
  final String searchQuery;
  final String rolFilter; // 'todos', 'cliente', 'instructor', 'recepcionista'
  final String estadoFilter; // 'todos', 'activo', 'suspendido'
  final String? errorMessage;

  const UsersAdminState({
    this.isLoading = false,
    this.usuarios = const [],
    this.searchQuery = '',
    this.rolFilter = 'todos',
    this.estadoFilter = 'todos',
    this.errorMessage,
  });

  List<AdminUserModel> get filteredUsuarios {
    return usuarios.where((u) {
      if (rolFilter != 'todos' && u.rol.toLowerCase() != rolFilter.toLowerCase()) {
        return false;
      }
      if (estadoFilter != 'todos') {
        final bool shouldBeActive = estadoFilter == 'activo';
        if (u.isActivo != shouldBeActive) return false;
      }
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final name = u.nombreCompleto.toLowerCase();
        final email = u.email.toLowerCase();
        final ci = (u.ci ?? '').toLowerCase();
        final cod = (u.codigo ?? '').toLowerCase();
        return name.contains(q) ||
            email.contains(q) ||
            ci.contains(q) ||
            cod.contains(q);
      }
      return true;
    }).toList();
  }

  UsersAdminState copyWith({
    bool? isLoading,
    List<AdminUserModel>? usuarios,
    String? searchQuery,
    String? rolFilter,
    String? estadoFilter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UsersAdminState(
      isLoading: isLoading ?? this.isLoading,
      usuarios: usuarios ?? this.usuarios,
      searchQuery: searchQuery ?? this.searchQuery,
      rolFilter: rolFilter ?? this.rolFilter,
      estadoFilter: estadoFilter ?? this.estadoFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final usersAdminNotifierProvider =
    NotifierProvider<UsersAdminNotifier, UsersAdminState>(
  UsersAdminNotifier.new,
);

class UsersAdminNotifier extends Notifier<UsersAdminState> {
  late final UsersRemoteDataSource _dataSource;

  @override
  UsersAdminState build() {
    _dataSource = ref.watch(usersRemoteDataSourceProvider);
    Future.microtask(() => cargarUsuarios());
    return const UsersAdminState(isLoading: true);
  }

  Future<void> cargarUsuarios() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _dataSource.getUsers();
      state = state.copyWith(isLoading: false, usuarios: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cargar usuarios: $e',
      );
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setRolFilter(String rol) {
    state = state.copyWith(rolFilter: rol);
  }

  void setEstadoFilter(String estado) {
    state = state.copyWith(estadoFilter: estado);
  }

  Future<bool> toggleUserStatus(int id, String currentStatus) async {
    try {
      await _dataSource.toggleUserStatus(id, currentStatus);
      await cargarUsuarios();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al actualizar estado: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _dataSource.deleteUser(id);
      await cargarUsuarios();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error al eliminar usuario: $e');
      return false;
    }
  }
}
