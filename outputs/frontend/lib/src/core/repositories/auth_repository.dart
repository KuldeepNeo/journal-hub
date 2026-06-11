import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../models/models.dart';

class AuthRepository {
  final ApiClient _apiClient;

  // Keep a mock store for simulated endpoints not yet integrated (Module 2+)
  final Map<String, String> _users = {
    'verified@example.com': 'Password123!',
    'pending@example.com': 'Password123!',
    'disabled@example.com': 'Password123!',
  };
  final Map<String, String> _statuses = {
    'verified@example.com': 'Verified',
    'pending@example.com': 'Pending',
    'disabled@example.com': 'Disabled',
  };
  final Map<String, String> _names = {
    'verified@example.com': 'Jane Doe',
    'pending@example.com': 'John Doe',
    'disabled@example.com': 'Block User',
  };

  AuthRepository(this._apiClient);

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate networking
    if (!_users.containsKey(email) || _users[email] != password) {
      throw Exception('INVALID_CREDENTIALS');
    }
    final status = _statuses[email]!;
    if (status == 'Pending') {
      throw Exception('ACCOUNT_NOT_VERIFIED');
    } else if (status == 'Disabled') {
      throw Exception('ACCOUNT_DISABLED');
    }
    return User(
      userId: email == 'verified@example.com' ? 'user-1' : 'user-3',
      fullName: _names[email]!,
      email: email,
      accountStatus: status,
    );
  }

  Future<User> register(String fullName, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      final data = response.data;
      return User(
        userId: data['userId'],
        fullName: fullName,
        email: email,
        accountStatus: data['accountStatus'],
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final errCode = e.response!.data['errorCode'];
        throw Exception(errCode ?? 'REGISTRATION_FAILED');
      }
      throw Exception('CONNECTION_ERROR');
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.dio.post('/auth/verify-email', data: {
        'verificationToken': token,
      });
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final errCode = e.response!.data['errorCode'];
        throw Exception(errCode ?? 'VERIFICATION_FAILED');
      }
      throw Exception('CONNECTION_ERROR');
    }
  }

  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_users.containsKey(email)) {
      throw Exception('INVALID_EMAIL');
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (token != '123456') {
      throw Exception('INVALID_TOKEN');
    }
  }
}
