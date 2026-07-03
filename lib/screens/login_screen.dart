import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_theme.dart';
import '../api/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Validation
    if (_emailController.text.isEmpty) {
      _showSnackBar(AppStrings.emailRequiredError);
      return;
    }

    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar(AppStrings.emailInvalidError);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar(AppStrings.passwordRequiredError);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar(AppStrings.passwordMinError);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showSnackBar('Login berhasil! Selamat datang ${user.name}');
        
        // Navigate to Dashboard
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top white space
            const SizedBox(height: 60),

            // Logo / Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBright,
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 45,
              ),
            ),

            const SizedBox(height: 24),

            // App Title
            Text(
              AppStrings.appName,
              style: AppTheme.headingXL,
            ),

            const SizedBox(height: 8),

            // App Subtitle
            Text(
              AppStrings.appSubtitle,
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall,
            ),

            const SizedBox(height: 48),

            // Form Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Email TextField
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.getInputDecoration(
                      hint: AppStrings.emailHint,
                      prefixIcon: Icons.email_outlined,
                    ),
                    style: AppTheme.bodyMedium,
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: AppStrings.passwordHint,
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: AppColors.primaryBright,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.primaryBright,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBright,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: AppTheme.bodyMedium,
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: AppTheme.getPrimaryButtonStyle().copyWith(
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              AppStrings.loginButton,
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/register');
                              },
                        child: Text(
                          'Daftar di sini',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.primaryBright,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
