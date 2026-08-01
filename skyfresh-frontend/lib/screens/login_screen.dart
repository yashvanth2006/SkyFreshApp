import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api_service.dart';
import 'home_screen.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '392048098425-3rjjq3pkkf22a4h0bllstov7f8jp4jv2.apps.googleusercontent.com',
  );

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);

    try {
      print('🔐 Starting Google Sign-In...');
      
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        if (!mounted) return;
        _showSnack('Sign-in cancelled');
        return;
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if idToken is null
      if (googleAuth.idToken == null) {
        print('❌ Failed to obtain ID Token from Google');
        throw Exception('Failed to obtain ID Token from Google');
      }

      print('✅ Google ID Token obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔑 Signing in to Firebase with Google credential...');
      
      // Sign in to Firebase with the Google credential
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      print('✅ Firebase sign-in successful');

      // Get the Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      
      if (!mounted) return;

      if (idToken == null) {
        _showSnack('Could not retrieve auth token. Please try again.');
        return;
      }

      // Exchange Firebase ID token for app JWT
      print('🔄 Exchanging Firebase token for app JWT...');
      final result = await ApiService.firebaseLogin(idToken);

      if (!mounted) return;

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
    } catch (e) {
      print('❌ Google Sign-In error: ${e.toString()}');
      if (!mounted) return;
      _showSnack(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
                  const SizedBox(height: 40),
                  
                  GestureDetector(
                    onTap: _loading ? null : _signInWithGoogle,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: _loading
                            ? []
                            : [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google_logo.png',
                                    height: 24,
                                    width: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.g_mobiledata, size: 24);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Continue with Google',
                                      style: TextStyle(
                                          color: AppTheme.textMain,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign in securely with your Google account',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
