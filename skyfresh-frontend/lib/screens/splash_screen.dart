import 'package:flutter/material.dart';
import 'package:skyfresh/ApiService.dart';
import 'package:skyfresh/theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    
    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      bool loggedIn = await ApiService.isLoggedIn();
      if (!mounted) return;
      
      if (loggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primaryDark.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.primary.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        gradient: AppTheme.glassGradient,
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30, offset: const Offset(0, 15)
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text('🌿', style: TextStyle(fontSize: 54)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800,
                            letterSpacing: -1, color: AppTheme.textMain),
                        children: [
                          TextSpan(text: 'SKY', style: TextStyle(color: Colors.white54)),
                          TextSpan(text: 'fresh', style: TextStyle(color: AppTheme.primaryLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Text('FARM FRESH  ·  SKY CLEAN',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted,
                            letterSpacing: 4, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 60),
                    const SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}