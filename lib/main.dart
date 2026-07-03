import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'constants/app_strings.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/category_list_screen.dart';
import 'screens/item_list_screen.dart';
import 'api/api_client.dart';

void main() async {
  // Initialize ApiClient before running the app
  await ApiClient().initialize();
  runApp(const OpticVaultApp());
}

class OpticVaultApp extends StatelessWidget {
  const OpticVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/categories': (context) => const CategoryListScreen(),
        '/items': (context) => const ItemListScreen(),
      },
    );
  }
}