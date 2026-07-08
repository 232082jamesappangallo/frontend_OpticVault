import 'package:flutter/material.dart';
import '../api/category_service.dart';
import '../api/item_service.dart';
import '../constants/app_theme.dart';
import '../constants/app_colors.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  final ItemService _itemService = ItemService();
  
  List<Map<String, dynamic>> categories = []; // Store id and name
  bool isLoading = true;
  Map<String, dynamic>? selectedCategory;
  List<dynamic> categoryItems = [];
  bool showingItems = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      // Get categories from API - now returns full objects with IDs
      final cats = await _categoryService.getCategories();
      
      setState(() {
        categories = cats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _loadCategoryItems(String categoryName) async {
    try {
      final items = await _itemService.getItemsByCategory(categoryName);
      setState(() {
        selectedCategory = {'name': categoryName};
        categoryItems = items;
        showingItems = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: controller,
            decoration: AppTheme.getInputDecoration(
              hint: 'Nama Kategori',
              prefixIcon: Icons.label_outline,
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final newCategory = controller.text.trim();
                      if (newCategory.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama kategori tidak boleh kosong'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        await _categoryService.createCategory(newCategory);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kategori "$newCategory" ditambahkan'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadCategories();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                          );
                        }
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final TextEditingController controller = TextEditingController(text: category['name']);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Kategori'),
          content: TextField(
            controller: controller,
            decoration: AppTheme.getInputDecoration(
              hint: 'Nama Kategori',
              prefixIcon: Icons.label_outline,
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final newName = controller.text.trim();
                      if (newName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama kategori tidak boleh kosong'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      if (newName == category['name']) {
                        Navigator.pop(context);
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        // Note: Backend should support finding by name for now
                        await _categoryService.updateCategory(category['id'], newName);
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kategori diubah menjadi "$newName"'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _loadCategories();
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                          );
                        }
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCategoryDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _categoryService.deleteCategory(category['id']);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kategori "${category['name']}" dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadCategories();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showingItems) {
          setState(() {
            showingItems = false;
            selectedCategory = null;
            categoryItems = [];
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: showingItems
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      showingItems = false;
                      selectedCategory = null;
                      categoryItems = [];
                    });
                  },
                )
              : null,
          title: Text(showingItems ? 'Item di "${selectedCategory?['name']}"' : 'Kelola Kategori'),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: AppColors.backgroundLight,
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.primaryBright),
              )
            : showingItems
                ? _buildItemsList()
                : _buildCategoryList(),
        floatingActionButton: !showingItems
            ? FloatingActionButton(
                onPressed: _showAddCategoryDialog,
                backgroundColor: AppColors.primaryBright,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryList() {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Belum ada kategori',
              style: AppTheme.headingMedium.copyWith(color: AppColors.textGray),
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan kategori baru untuk mulai',
              style: AppTheme.bodyMedium.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          decoration: AppTheme.getCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: AppColors.accentOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Category Name and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'],
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jenis barang optik',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Action Menu
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('Lihat Items'),
                        ],
                      ),
                      onTap: () => _loadCategoryItems(category['name']),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                      onTap: () => _showEditCategoryDialog(category),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => _showDeleteCategoryDialog(category),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsList() {
    if (categoryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Tidak ada item',
              style: AppTheme.headingMedium.copyWith(color: AppColors.textGray),
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan item ke kategori "${selectedCategory?['name']}"',
              style: AppTheme.bodyMedium.copyWith(color: AppColors.textGray),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categoryItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = categoryItems[index];
        
        // Handle both ItemModel and Map types
        final String itemName = item is Map ? (item['name'] ?? 'Unknown') : (item.name ?? 'Unknown');
        final int itemQty = item is Map ? (item['quantity'] ?? 0) : (item.quantity ?? 0);
        final String itemCondition = item is Map ? (item['condition'] ?? 'Baik') : (item.condition ?? 'Baik');
        final String itemDesc = item is Map ? (item['description'] ?? '') : (item.description ?? '');
        final String itemLoc = item is Map ? (item['location'] ?? 'N/A') : (item.location ?? 'N/A');
        
        return Container(
          decoration: AppTheme.getCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name and Condition
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        style: AppTheme.headingSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: itemCondition == 'Baik'
                            ? AppColors.success.withOpacity(0.1)
                            : itemCondition == 'Rusak'
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        itemCondition,
                        style: AppTheme.labelMedium.copyWith(
                          color: itemCondition == 'Baik'
                              ? AppColors.success
                              : itemCondition == 'Rusak'
                                  ? AppColors.error
                                  : AppColors.info,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  itemDesc,
                  style: AppTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Details Row: Quantity | Location
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$itemQty pcs',
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      itemLoc,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
