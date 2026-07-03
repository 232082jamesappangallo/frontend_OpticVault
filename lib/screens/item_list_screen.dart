import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../models/item_model.dart';
import '../api/item_service.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({Key? key}) : super(key: key);

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final ItemService _itemService = ItemService();
  late Future<List<ItemModel>> _itemsFuture;
  String _selectedCategory = 'Semua';
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _itemService.getCategories();
    _itemsFuture = _itemService.getItems();
  }

  void _refreshItems() {
    setState(() {
      if (_selectedCategory == 'Semua') {
        _itemsFuture = _itemService.getItems();
      } else {
        _itemsFuture = _itemService.getItemsByCategory(_selectedCategory);
      }
    });
  }

  void _showDeleteDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _itemService.deleteItem(item.id).then((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Barang dihapus')),
                  );
                  _refreshItems();
                }
              }).catchError((e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              });
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final quantityController = TextEditingController(text: '0');
    final locationController = TextEditingController();
    String selectedCategory = 'Kamera';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Barang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Nama Barang',
                  prefixIcon: Icons.videocam_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Deskripsi',
                  prefixIcon: Icons.description_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Jumlah',
                  prefixIcon: Icons.numbers,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Lokasi',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  descController.text.isEmpty ||
                  quantityController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Semua field wajib diisi')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              _itemService
                  .createItem(
                name: nameController.text,
                description: descController.text,
                category: selectedCategory,
                quantity: int.parse(quantityController.text),
                location: locationController.text.isEmpty
                    ? null
                    : locationController.text,
              )
                  .then((_) {
                // Use screen context, not dialog context
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Barang ditambahkan')),
                  );
                  _refreshItems();
                }
              }).catchError((e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              });
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(ItemModel item) {
    final nameController = TextEditingController(text: item.name);
    final descController = TextEditingController(text: item.description);
    final quantityController =
        TextEditingController(text: item.quantity.toString());
    final locationController = TextEditingController(text: item.location ?? '');
    String selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Barang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Nama Barang',
                  prefixIcon: Icons.videocam_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Deskripsi',
                  prefixIcon: Icons.description_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Jumlah',
                  prefixIcon: Icons.numbers,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: AppTheme.getInputDecoration(
                  hint: 'Lokasi',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  descController.text.isEmpty ||
                  quantityController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Semua field wajib diisi')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              _itemService
                  .updateItem(
                item.id,
                name: nameController.text,
                description: descController.text,
                category: selectedCategory,
                quantity: int.parse(quantityController.text),
                location: locationController.text.isEmpty
                    ? null
                    : locationController.text,
              )
                  .then((_) {
                // Use screen context, not dialog context
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Barang diperbarui')),
                  );
                  _refreshItems();
                }
              }).catchError((e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              });
            },
            child: const Text('Simpan'),
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
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Category Filter
          FutureBuilder<List<String>>(
            future: _categoriesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 60);
              }

              final categories = ['Semua', ...snapshot.data!];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              _refreshItems();
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primaryBright,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryBright
                                : AppColors.borderLight,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          // Items List
          Expanded(
            child: FutureBuilder<List<ItemModel>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBright,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                          style:
                              AppTheme.bodySmall.copyWith(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshItems,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.textGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada barang',
                          style: AppTheme.bodyLarge
                              .copyWith(color: AppColors.textGray),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan barang baru untuk mulai',
                          style: AppTheme.bodySmall
                              .copyWith(color: AppColors.textGray),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      decoration: AppTheme.getCardDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppTheme.headingSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.condition ?? 'Baik',
                                    style: AppTheme.labelMedium.copyWith(
                                      color: AppColors.success,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Description
                            Text(
                              item.description,
                              style: AppTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            // Details Row
                            Row(
                              children: [
                                // Category
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryBright.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: AppTheme.labelMedium.copyWith(
                                      color: AppColors.primaryBright,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Quantity
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 14,
                                  color: AppColors.textGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.quantity} pcs',
                                  style: AppTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _showEditItemDialog(item),
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 16),
                                    label: const Text('Edit'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _showDeleteDialog(item),
                                    icon: const Icon(Icons.delete_outlined,
                                        size: 16),
                                    label: const Text('Hapus'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(
                                          color: AppColors.error),
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
                );
              },
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
