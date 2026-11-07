import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String? tokenType;
  final String? message;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    this.tokenType,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final userMap = rawUser is Map<String, dynamic> ? rawUser : json;
    final token = json['access_token'] as String? ?? json['token'] as String? ?? '';

    return AuthResponseModel(
      user: UserModel.fromJson(userMap),
      accessToken: token,
      tokenType: json['token_type'] as String?,
      message: json['message'] as String?,
    );
  }
}
