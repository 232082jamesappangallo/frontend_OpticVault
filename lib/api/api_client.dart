import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class ApiClient {
  // URL Backend - sesuaikan dengan environment
  // Web/Desktop: localhost:8000
  // Android Emulator: 10.0.2.2:8000 (for BlueStacks or Android AVD)
  // Physical Device: Host IP:8000
  static String get baseUrl {
    if (Platform.isAndroid) {
      // For Android emulator (including BlueStacks) - use 10.0.2.2 to reach host
      return 'http://10.56.37.165:8000/api';
    } else if (Platform.isIOS) {
      // For iOS simulator
      return 'http://localhost:8000/api';
    } else {
      // For Web, Desktop (Windows, macOS, Linux)
      return 'http://localhost:8000/api';
    }
  }
  static const String _tokenKey = 'auth_token';
  
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  
  String? _token;
  SharedPreferences? _prefs;

  ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  /// Get or initialize SharedPreferences (lazy init)
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Initialize and load token from storage
  Future<void> initialize() async {
    try {
      final prefs = await _getPrefs();
      _token = prefs.getString(_tokenKey);
      print('🔑 ApiClient initialized. Token from storage: ${_token != null ? _token : 'NONE'}');
    } catch (e) {
      print('❌ Failed to initialize ApiClient: $e');
    }
  }

  /// Set JWT token untuk authenticated requests
  Future<void> setToken(String token) async {
    try {
      _token = token;
      final prefs = await _getPrefs();
      await prefs.setString(_tokenKey, token);
      print('💾 Token saved: $token');
    } catch (e) {
      print('❌ Failed to set token: $e');
    }
  }

  /// Clear token (logout)
  Future<void> clearToken() async {
    try {
      _token = null;
      final prefs = await _getPrefs();
      await prefs.remove(_tokenKey);
      print('🗑️ Token cleared');
    } catch (e) {
      print('❌ Failed to clear token: $e');
    }
  }

  /// Ensure token is loaded into memory from storage
  Future<void> _ensureTokenLoaded() async {
    if (_token == null) {
      final prefs = await _getPrefs();
      _token = prefs.getString(_tokenKey);
      if (_token != null) {
        print('🔄 Token loaded from storage for request: $_token');
      }
    }
  }

  /// Get headers dengan authorization jika token ada
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      print('🔐 Token included: $_token');
    } else {
      print('⚠️ No token found in memory!');
    }
    
    return headers;
  }

  /// GET request
  Future<dynamic> get(String endpoint) async {
    try {
      await _ensureTokenLoaded();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      await _ensureTokenLoaded();
      print('📤 POST $endpoint');
      print('📊 Body: ${jsonEncode(data ?? {})}');
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data ?? {}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('📥 Response status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      await _ensureTokenLoaded();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data ?? {}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      await _ensureTokenLoaded();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Handle response dan error
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = utf8.decode(response.bodyBytes);

    try {
      final jsonResponse = jsonDecode(body);

      if (statusCode >= 200 && statusCode < 300) {
        return jsonResponse;
      } else if (statusCode == 401) {
        // Don't clear token here since clearToken is async
        // Token will be cleared when needed
        throw Exception('Unauthorized - Please login again');
      } else if (statusCode == 403) {
        throw Exception('Forbidden - Access denied');
      } else if (statusCode == 404) {
        throw Exception('Not Found');
      } else if (statusCode == 422) {
        // Validation error
        final errors = jsonResponse['errors'] ?? jsonResponse['message'];
        throw Exception('Validation Error: $errors');
      } else if (statusCode >= 500) {
        throw Exception('Server Error: ${jsonResponse['message'] ?? 'Unknown error'}');
      } else {
        throw Exception('${jsonResponse['message'] ?? 'Request failed with status: $statusCode'}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to parse response: $e');
    }
  }
}
