import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api_service.dart';
import 'home_screen.dart';
import '../theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String verificationId;

  /// Present only when Firebase auto-verified (Android instant verification).
  final PhoneAuthCredential? autoCredential;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    this.autoCredential,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // If Firebase already auto-verified (e.g. Android instant verify),
    // skip manual entry and sign in right away.
    if (widget.autoCredential != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _signInWithCredential(widget.autoCredential!);
      });
    }
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final smsCode = _otpCtrl.text.trim();
    if (smsCode.length < 6) {
      _showSnack('Please enter the 6-digit OTP');
      return;
    }

    setState(() => _loading = true);
    print('🔐 Verifying OTP code: $smsCode');

    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    await _signInWithCredential(credential);
  }

  Future<void> _signInWithCredential(
      PhoneAuthCredential credential) async {
    try {
      print('🔑 Signing in with credential...');
      final userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Get the Firebase ID token to exchange for our app JWT.
      final idToken =
          await userCredential.user?.getIdToken();

      print('✅ Firebase ID token retrieved: ${idToken != null ? "Success" : "Failed"}');

      if (!mounted) return;

      if (idToken == null) {
        setState(() => _loading = false);
        _showSnack('Could not retrieve auth token. Please try again.');
        return;
      }

      // Exchange Firebase ID token → app JWT from our backend.
      print('🔄 Exchanging Firebase token for app JWT...');
      final result = await ApiService.firebaseLogin(idToken);

      if (!mounted) return;
      setState(() => _loading = false);

      if (result['success'] == true) {
        print('✅ Login successful');
        _showSnack('Welcome to SKYfresh! 🌿');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        print('❌ Backend login failed: ${result['message']}');
        _showSnack(result['message'] ?? 'Login failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      if (!mounted) return;
      setState(() => _loading = false);
      String msg = 'OTP verification failed';
      if (e.code == 'invalid-verification-code') {
        msg = 'Invalid OTP. Please check and try again.';
      } else if (e.code == 'session-expired') {
        msg = 'OTP expired. Go back and request a new one.';
      } else if (e.message != null) {
        msg = e.message!;
      }
      _showSnack(msg);
    } catch (e) {
      print('❌ Unexpected error: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack('Something went wrong: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
                boxShadow: [AppTheme.cardShadow],
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter OTP',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.5,
                          color: AppTheme.textMain)),
                  const SizedBox(height: 12),
                  Text(
                      'Enter the 6-digit code sent via SMS to ${widget.phone}',
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (widget.autoCredential != null)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryDark),
                          SizedBox(width: 16),
                          Text('Auto-verifying…',
                              style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  else ...[
                    TextFormField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textMain,
                          fontSize: 28,
                          letterSpacing: 12,
                          fontWeight: FontWeight.w800),
                      decoration:
                          _inputDecoration('OTP', Icons.lock_outline)
                              .copyWith(
                        counterText: '',
                        hintText: '000000',
                        hintStyle:
                            const TextStyle(letterSpacing: 12, color: Colors.black26),
                      ),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: _loading ? null : _verifyOtp,
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: _loading ? null : AppTheme.greenGradient,
                          color: _loading ? AppTheme.surfaceMuted : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _loading
                              ? []
                              : [
                                  BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8))
                                ],
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child:
                                      CircularProgressIndicator(
                                          color: AppTheme.primaryDark,
                                          strokeWidth: 3))
                              : const Text('Verify & Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppTheme.border.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent)),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
  }
}
