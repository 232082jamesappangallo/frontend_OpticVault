import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../api/item_service.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final ItemService _itemService = ItemService();
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _itemService.getCategories();
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _itemService.getCategories();
    });
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: nameController,
          decoration: AppTheme.getInputDecoration(
            hint: 'Nama Kategori',
            prefixIcon: Icons.label_outline,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
                );
                return;
              }
              Navigator.pop(context);
              _refreshCategories();
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture,
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
                    style: AppTheme.bodySmall.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCategories,
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
                    Icons.folder_open_outlined,
                    size: 64,
                    color: AppColors.textGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kategori',
                    style: AppTheme.bodyLarge.copyWith(color: AppColors.textGray),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan kategori baru untuk mulai',
                    style: AppTheme.bodySmall.copyWith(color: AppColors.textGray),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                decoration: AppTheme.getCardDecoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.label_outlined,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  title: Text(
                    category,
                    style: AppTheme.headingSmall,
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit coming soon...')),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Hapus'),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Delete coming soon...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: AppColors.primaryBright,
        child: const Icon(Icons.add),
      ),
    );
  }
}
