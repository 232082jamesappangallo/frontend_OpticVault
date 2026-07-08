import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_theme.dart';
import '../models/item_model.dart';
import '../api/item_service.dart';
import '../api/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  
  late Future<List<ItemModel>> _recentItemsFuture;
  bool _isLoadingLogout = false;

  @override
  void initState() {
    super.initState();
    _recentItemsFuture = _itemService.getRecentItems(limit: 3);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() {
                _isLoadingLogout = true;
              });

              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoadingLogout = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${e.toString().replaceFirst('Exception: ', '')}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  // Still navigate to login even if logout fails
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  });
                }
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _isLoadingLogout ? null : _handleLogout,
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.welcomeMessage,
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.welcomeSubtitle,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Grid Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Row 1: Kelola Kategori
                  _buildMenuCard(
                    title: 'Kelola Kategori',
                    subtitle: 'Tambah, edit, dan hapus kategori barang',
                    icon: Icons.folder_outlined,
                    iconColor: AppColors.accentOrange,
                    onTap: () {
                      Navigator.pushNamed(context, '/categories');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Kelola Barang
                  _buildMenuCard(
                    title: 'Kelola Barang',
                    subtitle: 'Tambah, edit, dan hapus barang inventaris',
                    icon: Icons.inventory_2_outlined,
                    iconColor: AppColors.accentGreen,
                    onTap: () {
                      Navigator.pushNamed(context, '/items');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recent Items Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.recentItems,
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<ItemModel>>(
                    future: _recentItemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBright,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              AppStrings.noRecentItems,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColors.textGray,
                              ),
                            ),
                          ),
                        );
                      }

                      final items = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildItemCard(item);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.getCardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryBright,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(ItemModel item) {
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
                    item.name,
                    style: AppTheme.headingSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.condition ?? 'Baik',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.success,
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

            // Details Row: Category | Location | Quantity
            Row(
              children: [
                // Category Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category,
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.primaryBright,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Location Icon + Text
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textGray,
                ),
                const SizedBox(width: 4),
                Text(
                  item.location ?? 'N/A',
                  style: AppTheme.bodySmall,
                ),
                const Spacer(),

                // Quantity
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.quantity} pcs',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppColors.info,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
