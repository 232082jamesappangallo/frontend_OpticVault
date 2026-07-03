import 'api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Login dengan email dan password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response['data'] != null) {
        final userJson = response['data'];
        final user = UserModel.fromJson(userJson);
        
        // Set token untuk request selanjutnya
        if (user.token != null) {
          await _apiClient.setToken(user.token!);
        }
        
        return user;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Register user baru
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response['data'] != null) {
        final userJson = response['data'];
        final user = UserModel.fromJson(userJson);
        
        if (user.token != null) {
          await _apiClient.setToken(user.token!);
        }
        
        return user;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Get current user profile
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');

      if (response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Get profile failed: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
      await _apiClient.clearToken();
    } catch (e) {
      // Always clear token even if logout request fails
      // This ensures the user can logout from frontend
      await _apiClient.clearToken();
      
      // Don't throw exception - just log it
      print('⚠️ Logout API error (token cleared anyway): $e');
    }
  }

  /// Set token dari storage (untuk resume session)
  Future<void> setToken(String token) async {
    await _apiClient.setToken(token);
  }

  /// Clear token
  Future<void> clearToken() async {
    await _apiClient.clearToken();
  }
}
