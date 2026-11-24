import 'dart:convert';
import 'package:savefood/core/network/api_client.dart';
import 'package:savefood/core/network/token_storage.dart';
import 'package:savefood/shared/models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? phone,
    String? businessName,
    String? businessDescription,
    String? address,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
    };
    if (phone != null) body['phone'] = phone;
    if (businessName != null) body['business_name'] = businessName;
    if (businessDescription != null) body['business_description'] = businessDescription;
    if (address != null) body['address'] = address;

    final response = await _api.post('/register', body: body);
    final authResponse = AuthResponse.fromJson(response);

    await TokenStorage.saveToken(authResponse.token);
    await TokenStorage.saveUserJson(jsonEncode(response['user']));

    return authResponse;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/login', body: {
      'email': email,
      'password': password,
    });

    final authResponse = AuthResponse.fromJson(response);

    await TokenStorage.saveToken(authResponse.token);
    await TokenStorage.saveUserJson(jsonEncode(response['user']));

    return authResponse;
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout', auth: true);
    } catch (_) {}
    await TokenStorage.clear();
  }

  Future<UserModel?> getUser() async {
    try {
      final response = await _api.get('/user', auth: true);
      return UserModel.fromJson(response['user']);
    } catch (_) {
      return null;
    }
  }
}
