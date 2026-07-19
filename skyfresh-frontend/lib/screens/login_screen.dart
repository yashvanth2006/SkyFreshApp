import 'package:flutter/material.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/theme.dart';
import 'register_screen.dart';
import 'package:skyfresh/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await ApiService.login(
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryDark,
        content: const Text('Welcome back to SKYfresh! 🌿', style: TextStyle(color: Colors.white))));
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(result['message'] ?? 'Login failed', style: const TextStyle(color: Colors.white))));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 74, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border)
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🌿', style: TextStyle(fontSize: 14)),
                          SizedBox(width: 8),
                          Text('SKYfresh',
                            style: TextStyle(color: AppTheme.textMain,
                                fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Welcome back',
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.1,
                          letterSpacing: -1.2, color: AppTheme.textMain)),
                    const SizedBox(height: 10),
                    const Text('Shop premium groceries with instant delivery and smart savings.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 15,
                          fontWeight: FontWeight.w500, height: 1.5)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
                      validator: (v) => v!.length < 10 ? 'Enter valid phone number' : null,
                      decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
                      validator: (v) => v!.length < 6 ? 'Minimum 6 characters' : null,
                      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                              color: AppTheme.textMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        child: const Text('Forgot password?',
                          style: TextStyle(color: AppTheme.primary,
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: _loading ? null : _login,
                      child: Container(
                        width: double.infinity, height: 60,
                        decoration: BoxDecoration(
                          gradient: _loading ? null : AppTheme.greenGradient,
                          color: _loading ? AppTheme.surfaceLight : null,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: _loading ? [] : [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.3),
                              blurRadius: 20, offset: const Offset(0, 8)
                            )
                          ],
                        ),
                        child: Center(
                          child: _loading
                            ? const SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5))
                            : const Text('Sign In',
                                style: TextStyle(color: Colors.white, fontSize: 17,
                                    fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                          children: [
                            TextSpan(text: 'Sign up',
                              style: TextStyle(color: AppTheme.primary,
                                  fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 22),
      filled: true,
      fillColor: AppTheme.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent)),
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
    );
  }
}