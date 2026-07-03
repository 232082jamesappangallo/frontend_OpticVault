import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_theme.dart';
import '../api/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    // Validation
    if (_nameController.text.isEmpty) {
      _showSnackBar('Nama tidak boleh kosong');
      return;
    }

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

    if (_passwordController.text != _passwordConfirmController.text) {
      _showSnackBar('Konfirmasi password tidak sesuai');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showSnackBar('Registrasi berhasil! Silakan login');
        
        // Navigate to login
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
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
            const SizedBox(height: 40),

            // Logo / Icon
            Container(
              width: 70,
              height: 70,
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
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            // App Title
            Text(
              'Daftar ${AppStrings.appName}',
              style: AppTheme.headingLarge,
            ),

            const SizedBox(height: 8),

            // App Subtitle
            Text(
              'Buat akun baru Anda',
              textAlign: TextAlign.center,
              style: AppTheme.bodySmall,
            ),

            const SizedBox(height: 32),

            // Form Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Name TextField
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: AppTheme.getInputDecoration(
                      hint: 'Nama Lengkap',
                      prefixIcon: Icons.person_outline,
                    ),
                    style: AppTheme.bodyMedium,
                    enabled: !_isLoading,
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  // Confirm Password TextField
                  TextField(
                    controller: _passwordConfirmController,
                    obscureText: _obscurePasswordConfirm,
                    decoration: InputDecoration(
                      hintText: 'Konfirmasi Kata Sandi',
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: AppColors.primaryBright,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePasswordConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.primaryBright,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePasswordConfirm =
                                      !_obscurePasswordConfirm;
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

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
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
                              'DAFTAR',
                              style: AppTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: AppTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                        child: Text(
                          'Masuk',
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
