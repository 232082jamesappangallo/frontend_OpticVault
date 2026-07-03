import 'api_client.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  /// Get list of available categories (from items)
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/items');

      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        final categories = data
            .map((item) => item['category'] as String)
            .toSet()
            .toList();
        categories.sort();
        return categories;
      } else {
        return [];
      }
    } catch (e) {
      // Handle 401 - user should login again
      if (e.toString().contains('Unauthorized')) {
        throw Exception('Session expired - Please login again');
      }
      throw Exception('Get categories failed: $e');
    }
  }
}
