import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)],
                ),
                child: const Center(child: Text('✓', style: TextStyle(fontSize: 56, color: AppTheme.primary))),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed Successfully', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
              const SizedBox(height: 12),
              Text('Thank you for ordering with SKYfresh!\nOrder ID: $orderId', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textMuted)),
              const SizedBox(height: 18),
              const Text('Estimated Delivery: 45 - 60 mins', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
