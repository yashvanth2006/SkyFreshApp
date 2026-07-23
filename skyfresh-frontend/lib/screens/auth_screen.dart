import 'package:flutter/material.dart';
import '../api_service.dart';
import 'home_screen.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  
  bool _otpSent = false;
  bool _loading = false;
  
  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await ApiService.sendOtp(phone);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await ApiService.verifyOtp(phone, otp);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome to SKYfresh! 🌿')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
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
                  Text(
                    _otpSent ? 'Enter OTP' : 'Welcome',
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.1,
                        letterSpacing: -1.2, color: AppTheme.textMain)),
                  const SizedBox(height: 10),
                  Text(
                    _otpSent 
                        ? 'Enter the 4-digit code sent to your phone'
                        : 'Shop premium groceries with instant delivery and smart savings.',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 15,
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
                    enabled: !_otpSent,
                    style: const TextStyle(color: AppTheme.textMain, fontSize: 16),
                    validator: (v) => v!.length < 10 ? 'Enter valid phone number' : null,
                    decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 20),

                  if (_otpSent) ...[
                    TextFormField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textMain, fontSize: 24, letterSpacing: 8),
                      decoration: _inputDecoration('OTP', Icons.lock_outline).copyWith(
                        counterText: '',
                        hintText: '0000',
                        hintStyle: const TextStyle(letterSpacing: 8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GestureDetector(
                      onTap: () => setState(() => _otpSent = false),
                      child: const Text('Change phone number',
                        style: TextStyle(color: AppTheme.primary,
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  GestureDetector(
                    onTap: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
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
                            : Text(_otpSent ? 'Verify & Login' : 'Send OTP',
                                style: const TextStyle(color: Colors.white, fontSize: 17,
                                    fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
