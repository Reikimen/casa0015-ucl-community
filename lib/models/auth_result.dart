import 'user_model.dart';

class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? errorMessage;

  AuthResult({
    required this.success,
    this.user,
    this.token,
    this.errorMessage,
  });
}