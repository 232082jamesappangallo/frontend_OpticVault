import 'api_client.dart';
import 'package:opticvault/models/item_model.dart';

class ItemService {
  final ApiClient _apiClient = ApiClient();

  /// Get all items sebagai List<ItemModel>
  Future<List<ItemModel>> getItems() async {
    try {
      final response = await _apiClient.get('/items');
      
      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ItemModel.fromJson(item))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  /// Get all items (paginated) sebagai Map
  Future<Map<String, dynamic>> getAllItems({int page = 1, int perPage = 10}) async {
    try {
      final response = await _apiClient.get('/items?page=$page&per_page=$perPage');
      
      return {
        'data': response['data'] ?? [],
        'pagination': response['pagination'] ?? {},
      };
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  /// Get recent items sebagai List<ItemModel>
  Future<List<ItemModel>> getRecentItems({int limit = 5}) async {
    try {
      final response = await _apiClient.get('/items/recent?limit=$limit');
      
      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ItemModel.fromJson(item))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch recent items: $e');
    }
  }

  /// Get single item
  Future<dynamic> getItem(int id) async {
    try {
      final response = await _apiClient.get('/items/$id');
      return response['data'];
    } catch (e) {
      throw Exception('Failed to fetch item: $e');
    }
  }

  /// Get all categories dari items
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiClient.get('/items');
      
      if (response != null && response['data'] is List) {
        Set<String> categories = {};
        for (var item in response['data']) {
          if (item['category'] != null) {
            categories.add(item['category']);
          }
        }
        return categories.toList()..sort();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Create new item
  Future<dynamic> createItem({
    required String name,
    required String description,
    required String category,
    required int quantity,
    required String condition,
    String? location,
  }) async {
    try {
      final response = await _apiClient.post('/items', data: {
        'name': name,
        'description': description,
        'category': category,
        'quantity': quantity,
        'condition': condition,
        'location': location ?? '',
      });

      return response['data'];
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  /// Update item
  Future<dynamic> updateItem(
    int id, {
    required String name,
    required String description,
    required String category,
    required int quantity,
    required String condition,
    String? location,
  }) async {
    try {
      final response = await _apiClient.put('/items/$id', data: {
        'name': name,
        'description': description,
        'category': category,
        'quantity': quantity,
        'condition': condition,
        'location': location ?? '',
      });

      return response['data'];
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Delete item
  Future<void> deleteItem(int id) async {
    try {
      await _apiClient.delete('/items/$id');
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Get items by category sebagai List<ItemModel>
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/items/category/$category');
      
      if (response != null && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ItemModel.fromJson(item))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to fetch items by category: $e');
    }
  }

  /// Get condition options
  static List<String> getConditionOptions() {
    return ['Baik', 'Rusak', 'Perlu Perbaikan'];
  }
}
