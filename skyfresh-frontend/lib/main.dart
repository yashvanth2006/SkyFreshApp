import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kIsWeb) {
      print("Firebase web options not configured yet. App running without FCM web options.");
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyDhjuA8mWA5wv2azz4wikisliezetECmus',
            appId: '1:392048098425:android:5b71912a0d8f886809a8a8',
            messagingSenderId: '392048098425',
            projectId: 'skyfresh-3ddad',
          ),
        );
      } catch (e2) {
        print("Fallback Firebase initialization failed: $e2");
      }
    } else {
      print("Firebase initialization error: $e");
    }
  }
  runApp(const SKYfreshApp());
}

class SKYfreshApp extends StatelessWidget {
  const SKYfreshApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'SKYfresh',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppTheme.bg,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.textMain),
            titleTextStyle: TextStyle(color: AppTheme.textMain, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            },
          ),

        ),
        home: const SplashScreen(),
      ),
    );
  }
}