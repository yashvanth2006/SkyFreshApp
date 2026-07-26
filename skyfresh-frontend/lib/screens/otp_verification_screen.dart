import 'package:flutter/material.dart';
import '../api_service.dart';
import 'home_screen.dart';
import '../theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrl.text.trim();
    
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await ApiService.verifyOtp(widget.phone, otp);

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
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter OTP',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.1,
                        letterSpacing: -1.2, color: AppTheme.textMain)),
                  const SizedBox(height: 10),
                  Text('Enter the 6-digit code sent to ${widget.phone}',
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
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textMain, fontSize: 24, letterSpacing: 8),
                    decoration: _inputDecoration('OTP', Icons.lock_outline).copyWith(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: const TextStyle(letterSpacing: 8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: _loading ? null : _verifyOtp,
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
                            : const Text('Verify & Login',
                                style: TextStyle(color: Colors.white, fontSize: 17,
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
