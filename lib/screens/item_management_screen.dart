import 'package:flutter/material.dart';
import '../api/category_service.dart';
import '../api/item_service.dart';
import '../constants/app_theme.dart';
import '../constants/app_colors.dart';

class ItemManagementScreen extends StatefulWidget {
  const ItemManagementScreen({super.key});

  @override
  State<ItemManagementScreen> createState() => _ItemManagementScreenState();
}

class _ItemManagementScreenState extends State<ItemManagementScreen> {
  final ItemService _itemService = ItemService();
  final CategoryService _categoryService = CategoryService();
  
  List<dynamic> items = [];
  List<String> categories = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  String? selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      final cats = await _categoryService.getCategories();
      setState(() {
        // Extract category names from the list of maps
        if (cats.isNotEmpty) {
          categories = cats.map((cat) => cat['name'] as String).toList();
        } else {
          categories = CategoryService.getPredefinedCategories();
        }
      });
      await _loadPage(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadPage(int page) async {
    try {
      late Map<String, dynamic> itemsData;
      
      if (selectedCategoryFilter == null) {
        itemsData = await _itemService.getAllItems(page: page);
      } else {
        // Filter by category - get all and then paginate
        final allItems = await _itemService.getItemsByCategory(selectedCategoryFilter!);
        final itemsPerPage = 10;
        final totalItems = allItems.length;
        final lastPage = (totalItems / itemsPerPage).ceil();
        
        itemsData = {
          'data': allItems.skip((page - 1) * itemsPerPage).take(itemsPerPage).toList(),
          'pagination': {
            'current_page': page,
            'last_page': lastPage,
            'total': totalItems,
          }
        };
      }

      setState(() {
        items = itemsData['data'] ?? [];
        final pagination = itemsData['pagination'] as Map<String, dynamic>?;
        currentPage = pagination?['current_page'] ?? 1;
        totalPages = pagination?['last_page'] ?? 1;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
      setState(() => isLoading = false);
    }
  }

  void _showAddItemDialog() {
    _showItemDialog(null);
  }

  void _showEditItemDialog(dynamic item) {
    _showItemDialog(item);
  }

  void _showItemDialog(dynamic? item) {
    // Handle both ItemModel and Map types
    final String itemName = item == null ? '' : (item is Map ? (item['name'] ?? '') : (item.name ?? ''));
    final String itemDesc = item == null ? '' : (item is Map ? (item['description'] ?? '') : (item.description ?? ''));
    final int itemQty = item == null ? 0 : (item is Map ? (item['quantity'] ?? 0) : (item.quantity ?? 0));
    final String itemLoc = item == null ? '' : (item is Map ? (item['location'] ?? '') : (item.location ?? ''));
    final String itemCat = item == null ? (categories.isNotEmpty ? categories[0] : 'Umum') : (item is Map ? (item['category'] ?? 'Umum') : (item.category ?? 'Umum'));
    final String itemCond = item == null ? 'Baik' : (item is Map ? (item['condition'] ?? 'Baik') : (item.condition ?? 'Baik'));
    final int itemId = item == null ? 0 : (item is Map ? (item['id'] ?? 0) : (item.id ?? 0));
    
    final TextEditingController nameController = TextEditingController(text: itemName);
    final TextEditingController descriptionController = TextEditingController(text: itemDesc);
    final TextEditingController quantityController = TextEditingController(text: itemQty.toString());
    final TextEditingController locationController = TextEditingController(text: itemLoc);
    
    String selectedCategory = itemCat;
    String selectedCondition = itemCond;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Tambah Barang' : 'Edit Barang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: AppTheme.getInputDecoration(
                    hint: 'Nama Barang',
                    prefixIcon: Icons.inventory,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: AppTheme.getInputDecoration(
                    hint: 'Deskripsi',
                    prefixIcon: Icons.description,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: AppTheme.getInputDecoration(
                    hint: 'Jenis Barang',
                    prefixIcon: Icons.category,
                  ),
                  value: selectedCategory,
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  decoration: AppTheme.getInputDecoration(
                    hint: 'Jumlah',
                    prefixIcon: Icons.numbers,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: AppTheme.getInputDecoration(
                    hint: 'Lokasi (Opsional)',
                    prefixIcon: Icons.location_on,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: AppTheme.getInputDecoration(
                    hint: 'Kondisi',
                    prefixIcon: Icons.check_circle,
                  ),
                  value: selectedCondition,
                  items: ItemService.getConditionOptions()
                      .map((cond) => DropdownMenuItem(value: cond, child: Text(cond)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCondition = val);
                    }
                  },
                ),
              ],
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
                      final name = nameController.text.trim();
                      final description = descriptionController.text.trim();
                      final quantity = int.tryParse(quantityController.text) ?? 0;
                      final location = locationController.text.trim();

                      if (name.isEmpty || description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama dan deskripsi tidak boleh kosong'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        if (item == null) {
                          await _itemService.createItem(
                            name: name,
                            description: description,
                            category: selectedCategory,
                            quantity: quantity,
                            condition: selectedCondition,
                            location: location,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barang berhasil ditambahkan'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } else {
                          final itemId = item is Map ? item['id'] : item.id;
                          await _itemService.updateItem(
                            itemId,
                            name: name,
                            description: description,
                            category: selectedCategory,
                            quantity: quantity,
                            condition: selectedCondition,
                            location: location,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Barang berhasil diubah'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          _loadPage(currentPage);
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
                  : Text(item == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(dynamic item) {
    final String itemName = item is Map ? (item['name'] ?? 'Unknown') : (item.name ?? 'Unknown');
    final int itemId = item is Map ? (item['id'] ?? 0) : (item.id ?? 0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin ingin menghapus "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _itemService.deleteItem(itemId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barang berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadPage(currentPage);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Barang'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primaryBright),
            )
          : Column(
              children: [
                // Category Filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: selectedCategoryFilter,
                    hint: const Text('Filter by Category (All)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua Kategori')),
                      ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedCategoryFilter = val;
                        currentPage = 1;
                      });
                      _loadPage(1);
                    },
                  ),
                ),
                // Items List
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 24),
                              Text('Belum ada barang', style: AppTheme.headingMedium.copyWith(color: AppColors.textGray)),
                              const SizedBox(height: 12),
                              Text('Tambahkan barang baru dengan tombol +',
                                  style: AppTheme.bodyMedium.copyWith(color: AppColors.textGray)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            
                            // Handle both ItemModel and Map types
                            final String itemName = item is Map ? (item['name'] ?? 'Unknown') : (item.name ?? 'Unknown');
                            final int itemQty = item is Map ? (item['quantity'] ?? 0) : (item.quantity ?? 0);
                            final String itemCondition = item is Map ? (item['condition'] ?? 'Baik') : (item.condition ?? 'Baik');
                            final String itemDesc = item is Map ? (item['description'] ?? '') : (item.description ?? '');
                            final String itemCategory = item is Map ? (item['category'] ?? 'Umum') : (item.category ?? 'Umum');
                            
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

                                    // Details Row: Category | Quantity
                                    Row(
                                      children: [
                                        // Category
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBright.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            itemCategory,
                                            style: AppTheme.labelMedium.copyWith(
                                              color: AppColors.primaryBright,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Quantity
                                        Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.textGray),
                                        const SizedBox(width: 4),
                                        Text('$itemQty pcs', style: AppTheme.bodySmall),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showEditItemDialog(item),
                                            icon: const Icon(Icons.edit_outlined, size: 16),
                                            label: const Text('Edit'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showDeleteDialog(item),
                                            icon: const Icon(Icons.delete_outlined, size: 16),
                                            label: const Text('Hapus'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              foregroundColor: AppColors.error,
                                              side: const BorderSide(color: AppColors.error),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Pagination
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: currentPage > 1 ? () => _loadPage(currentPage - 1) : null,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Sebelumnya'),
                        ),
                        Text('Halaman $currentPage dari $totalPages', style: AppTheme.bodyMedium),
                        ElevatedButton.icon(
                          onPressed: currentPage < totalPages ? () => _loadPage(currentPage + 1) : null,
                          label: const Text('Berikutnya'),
                          icon: const Icon(Icons.arrow_forward, size: 18),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppColors.primaryBright,
        child: const Icon(Icons.add),
      ),
    );
  }
}
