import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/screens/splash_screen.dart';

void main() {
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
        ),
        home: const SplashScreen(),
      ),
    );
  }
}