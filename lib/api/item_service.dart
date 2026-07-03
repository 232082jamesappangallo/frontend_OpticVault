import 'api_client.dart';
import '../models/item_model.dart';

class ItemService {
  final ApiClient _apiClient = ApiClient();

  /// Get semua items
  Future<List<ItemModel>> getItems({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/items?page=$page&per_page=$perPage',
      );

      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      // Handle 401 - user should login again
      if (e.toString().contains('Unauthorized')) {
        throw Exception('Session expired - Please login again');
      }
      throw Exception('Get items failed: $e');
    }
  }

  /// Get recent items (untuk dashboard)
  Future<List<ItemModel>> getRecentItems({int limit = 3}) async {
    try {
      final response = await _apiClient.get('/items/recent?limit=$limit');

      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Get recent items failed: $e');
    }
  }

  /// Get item detail
  Future<ItemModel> getItemById(int id) async {
    try {
      final response = await _apiClient.get('/items/$id');

      if (response['data'] != null) {
        return ItemModel.fromJson(response['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Get item failed: $e');
    }
  }

  /// Get items by category
  Future<List<ItemModel>> getItemsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/items/category/$category');

      if (response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => ItemModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Get items by category failed: $e');
    }
  }

  /// Get all unique categories
  Future<List<String>> getCategories() async {
    try {
      final items = await getItems(perPage: 100);
      final categories = items.map((item) => item.category).toSet().toList();
      categories.sort();
      return categories;
    } catch (e) {
      throw Exception('Get categories failed: $e');
    }
  }

  /// Create item baru
  Future<ItemModel> createItem({
    required String name,
    required String description,
    required String category,
    required int quantity,
    String? location,
    String? condition,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'category': category,
        'quantity': quantity,
        'location': location,
        if (condition != null) 'condition': condition,
      };
      
      final response = await _apiClient.post(
        '/items',
        data: data,
      );

      if (response['data'] != null) {
        return ItemModel.fromJson(response['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Create item failed: $e');
    }
  }

  /// Update item
  Future<ItemModel> updateItem(
    int id, {
    required String name,
    required String description,
    required String category,
    required int quantity,
    String? location,
    String? condition,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'category': category,
        'quantity': quantity,
        'location': location,
        if (condition != null) 'condition': condition,
      };
      
      final response = await _apiClient.put(
        '/items/$id',
        data: data,
      );

      if (response['data'] != null) {
        return ItemModel.fromJson(response['data']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Update item failed: $e');
    }
  }

  /// Delete item
  Future<void> deleteItem(int id) async {
    try {
      await _apiClient.delete('/items/$id');
    } catch (e) {
      throw Exception('Delete item failed: $e');
    }
  }
}
