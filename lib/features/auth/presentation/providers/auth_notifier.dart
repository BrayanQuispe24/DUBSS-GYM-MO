import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRemoteDataSource _dataSource;
  late final SecureStorageService _storage;

  @override
  AuthState build() {
    _dataSource = ref.watch(authRemoteDataSourceProvider);
    _storage = ref.watch(secureStorageProvider);
    _initAuth();
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> _initAuth() async {
    try {
      final token = await _storage.getToken();
      final userJson = await _storage.getUser();

      if (token != null && token.isNotEmpty && userJson != null) {
        final user = UserModel.fromJsonString(userJson);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: token,
          user: user,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearError: true,
        );
      }
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearError: true,
      );
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _dataSource.login(
        identifier: identifier,
        password: password,
      );

      await _storage.saveToken(response.accessToken);
      await _storage.saveUser(response.user.toJsonString());

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: response.accessToken,
        user: response.user,
        clearError: true,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado al iniciar sesión',
      );
      return false;
    }
  }

  Future<bool> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String ci,
    required String registroUniversitario,
    required String tipoUsuario,
    String? telefono,
    bool aceptaTerminos = true,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _dataSource.registerCliente(
        nombre: nombre,
        apellido: apellido,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        ci: ci,
        registroUniversitario: registroUniversitario,
        tipoUsuario: tipoUsuario,
        telefono: telefono,
        aceptaTerminos: aceptaTerminos,
      );

      await _storage.saveToken(response.accessToken);
      await _storage.saveUser(response.user.toJsonString());

      state = state.copyWith(
        status: AuthStatus.authenticated,
        token: response.accessToken,
        user: response.user,
        clearError: true,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Error inesperado al registrar cuenta',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _dataSource.logout();
    } finally {
      await _storage.clearAuth();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
