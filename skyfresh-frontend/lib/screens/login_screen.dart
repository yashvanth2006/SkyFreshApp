import 'package:flutter/foundation.dart';
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
  final _nameCtrl = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '392048098425-3rjjq3pkkf22a4h0bllstov7f8jp4jv2.apps.googleusercontent.com' : null,
    serverClientId: kIsWeb ? null : '392048098425-3rjjq3pkkf22a4h0bllstov7f8jp4jv2.apps.googleusercontent.com',
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack('Please enter your name first');
      return;
    }

    setState(() => _loading = true);

    try {
      print('🔐 Starting Google Sign-In...');
      
      String? idToken;

      if (kIsWeb) {
        print('🌐 Using Firebase Auth Popup for Web...');
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        // Optional: add scopes if needed
        // googleProvider.addScope('email');
        
        final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        print('✅ Firebase sign-in successful');
        idToken = await userCredential.user?.getIdToken();
      } else {
        // Trigger the Google Sign-In flow for Android/iOS
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
        idToken = await userCredential.user?.getIdToken();
      }
      
      if (!mounted) return;

      if (idToken == null) {
        _showSnack('Could not retrieve auth token. Please try again.');
        return;
      }

      // Exchange Firebase ID token for app JWT with custom name
      print('🔄 Exchanging Firebase token for app JWT...');
      final result = await ApiService.firebaseLogin(idToken, name: name);

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
        borderSide: BorderSide(color: AppTheme.border.withValues(alpha: 0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
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
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
                boxShadow: [AppTheme.cardShadow],
              ),
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset('assets/icon.png', width: 20, height: 20, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        const Text('SKYfresh',
                            style: TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Welcome',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1.5,
                          color: AppTheme.textMain)),
                  const SizedBox(height: 12),
                  const Text(
                      'Shop premium groceries with instant delivery and smart savings.',
                      style: TextStyle(
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
                  const SizedBox(height: 48),
                  
                  TextFormField(
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: AppTheme.textMain, fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: _inputDecoration('Full Name', Icons.person_outline),
                  ),
                  const SizedBox(height: 24),
                  
                  GestureDetector(
                    onTap: _loading ? null : _signInWithGoogle,
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                        boxShadow: _loading ? [] : [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8))
                        ],
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/google_logo.png',
                                    height: 26,
                                    width: 26,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.g_mobiledata, size: 28);
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  const Text('Continue with Google',
                                      style: TextStyle(
                                          color: AppTheme.textMain,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2)),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sign in securely with your Google account',
                    style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
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
