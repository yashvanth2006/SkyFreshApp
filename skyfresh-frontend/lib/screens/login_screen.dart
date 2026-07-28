import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verification_screen.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Formats the user-entered number to E.164 (+91XXXXXXXXXX for India).
  String _toE164(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    if (digits.length == 10) return '+91$digits';
    return '+$digits'; // pass-through for already formatted numbers
  }

  Future<void> _sendOtp() async {
    final raw = _phoneCtrl.text.trim();
    if (raw.length < 10) {
      _showSnack('Please enter a valid phone number');
      return;
    }

    setState(() => _loading = true);

    final phoneNumber = _toE164(raw);
    print('📱 Sending OTP to phone: $phoneNumber');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // Called instantly on Android if Firebase can auto-verify (rare).
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verification completed');
          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            final idToken =
                await userCredential.user?.getIdToken();
            if (!mounted) return;
            if (idToken != null) {
              _navigateToOtp(phoneNumber, '', autoCredential: credential);
            }
          } catch (e) {
            print('❌ Auto-verification failed: $e');
            if (!mounted) return;
            setState(() => _loading = false);
            _showSnack('Auto-verification failed: $e');
          }
        },

        // Fires when Firebase sends the real SMS.
        codeSent: (String verificationId, int? resendToken) {
          print('✅ OTP code sent. Verification ID: $verificationId');
          if (!mounted) return;
          setState(() => _loading = false);
          _showSnack('OTP sent to $phoneNumber');
          _navigateToOtp(phoneNumber, verificationId);
        },

        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.code} - ${e.message}');
          if (!mounted) return;
          setState(() => _loading = false);
          _showSnack(e.message ?? 'Verification failed');
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏱️ Auto-retrieval timeout: $verificationId');
          // Auto-retrieval window closed; user must enter code manually.
        },

        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('❌ Unexpected error in verifyPhoneNumber: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Failed to send OTP: $e');
    }
  }

  void _navigateToOtp(String phone, String verificationId,
      {PhoneAuthCredential? autoCredential}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          phone: phone,
          verificationId: verificationId,
          autoCredential: autoCredential,
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 74, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text('SKYfresh',
                            style: TextStyle(
                                color: AppTheme.textMain,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Welcome',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.2,
                          color: AppTheme.textMain)),
                  const SizedBox(height: 10),
                  const Text(
                      'Shop premium groceries with instant delivery and smart savings.',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.5)),
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
                    style: const TextStyle(
                        color: AppTheme.textMain, fontSize: 16),
                    validator: (v) =>
                        v!.length < 10 ? 'Enter valid phone number' : null,
                    decoration:
                        _inputDecoration('Phone Number', Icons.phone_outlined),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your 10-digit mobile number. We\'ll send a real SMS OTP.',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _loading ? null : _sendOtp,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient:
                            _loading ? null : AppTheme.greenGradient,
                        color:
                            _loading ? AppTheme.surfaceLight : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _loading
                            ? []
                            : [
                                BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8))
                              ],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: AppTheme.primary,
                                    strokeWidth: 2.5))
                            : const Text('Send OTP',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5)),
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
      labelStyle:
          const TextStyle(color: AppTheme.textMuted, fontSize: 15),
      prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 22),
      filled: true,
      fillColor: AppTheme.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
    );
  }
}
