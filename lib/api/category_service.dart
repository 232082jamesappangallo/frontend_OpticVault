import 'api_client.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  /// Get all categories dari database
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      
      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .map((cat) => {
              'id': cat['id'] ?? 0,
              'name': cat['name'] ?? 'Unknown',
              'description': cat['description'] ?? '',
            })
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get predefined categories (static list for fallback)
  static List<String> getPredefinedCategories() {
    return [
      'Kacamata Minus',
      'Kacamata Plus',
      'Kacamata Silinder',
      'Lensa Kontak',
      'Lensa Replacement',
      'Frame Plastik',
      'Frame Metal',
      'Aksesoris',
      'Obat Mata',
      'Perawatan Lensa',
      'Umum',
    ];
  }

  /// Get items by category
  Future<List<dynamic>> getItemsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/items/category/$category');
      
      if (response != null && response['data'] is List) {
        return response['data'];
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch items for category: $e');
    }
  }

  /// Create new category
  Future<dynamic> createCategory(String name) async {
    try {
      final response = await _apiClient.post('/categories', data: {
        'name': name,
        'description': 'Jenis barang optik'
      });
      return response['data'];
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category
  Future<dynamic> updateCategory(int id, String name) async {
    try {
      final response = await _apiClient.put('/categories/$id', data: {
        'name': name,
        'description': 'Jenis barang optik'
      });
      return response['data'];
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete category
  Future<void> deleteCategory(int id) async {
    try {
      await _apiClient.delete('/categories/$id');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
