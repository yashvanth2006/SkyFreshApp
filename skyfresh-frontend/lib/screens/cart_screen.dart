import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/screens/checkout_screen.dart';
import 'package:skyfresh/theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _placingOrder = false;

  Future<void> _startCheckout(CartProvider cart, int subtotal, int deliveryFee, int grandTotal) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          grandTotal: grandTotal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final deliveryFee = cart.items.isEmpty ? 0 : (cart.totalPrice >= 200 ? 0 : 20);
    final grandTotal = cart.totalPrice + deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Cart 🛒',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5, color: AppTheme.textMain)),
                  if (cart.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text('${cart.totalItems} items',
                        style: const TextStyle(color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ),
                ],
              ),
            ),

            Expanded(
              child: cart.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.border, width: 2)
                          ),
                          child: const Center(
                            child: Text('🛒', style: TextStyle(fontSize: 44))),
                        ),
                        const SizedBox(height: 24),
                        const Text('Your cart is empty',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              letterSpacing: -0.3, color: AppTheme.textMain)),
                        const SizedBox(height: 8),
                        const Text('Add some premium fruits & juices!',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Dismissible(
                        key: ValueKey('${item.name}-${item.weight}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => context.read<CartProvider>()
                            .removeItem(item.name, item.weight),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 58, height: 58,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16)),
                                child: Center(
                                  child: Text(item.emoji,
                                    style: const TextStyle(fontSize: 28))),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                      style: const TextStyle(fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                          color: AppTheme.textMain)),
                                    const SizedBox(height: 2),
                                    Text(item.weight,
                                      style: const TextStyle(fontSize: 12,
                                          color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text('₹${item.total}',
                                      style: const TextStyle(fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryLight)),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Row(
                                  children: [
                                    _QtyBtn(
                                      icon: Icons.remove_rounded,
                                      onTap: () => context.read<CartProvider>()
                                          .decrement(item.name, item.weight),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      child: Text('${item.quantity}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                                    ),
                                    _QtyBtn(
                                      icon: Icons.add_rounded,
                                      onTap: () => context.read<CartProvider>()
                                          .increment(item.name, item.weight),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),

            if (cart.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20, offset: const Offset(0, -6))],
                ),
                child: Column(
                  children: [
                    _summaryRow('Subtotal', '₹${cart.totalPrice}'),
                    const SizedBox(height: 10),
                    _summaryRow(
                      'Delivery Fee',
                      deliveryFee == 0 ? 'FREE' : '₹$deliveryFee',
                      valueColor: deliveryFee == 0 ? AppTheme.primaryLight : AppTheme.textMain,
                    ),
                    if (deliveryFee > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border)
                        ),
                        child: Text('Add ₹${200 - cart.totalPrice} more for free delivery',
                          style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryLight,
                              fontWeight: FontWeight.w600)),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppTheme.border, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                              color: AppTheme.textMain)),
                        Text('₹$grandTotal',
                          style: const TextStyle(fontSize: 26,
                              fontWeight: FontWeight.w800, letterSpacing: -0.5,
                              color: AppTheme.textMain)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _placingOrder
                        ? null
                        : () => _startCheckout(cart, cart.totalPrice, deliveryFee, grandTotal),
                      child: Container(
                        width: double.infinity, height: 60,
                        decoration: BoxDecoration(
                          gradient: _placingOrder
                            ? null
                            : AppTheme.greenGradient,
                          color: _placingOrder ? AppTheme.surfaceLight : null,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: _placingOrder ? [] : [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.35),
                              blurRadius: 16, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Center(
                          child: _placingOrder
                            ? const SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.4))
                            : const Text('Proceed to Checkout',
                              style: TextStyle(color: Colors.white,
                                fontSize: 17, fontWeight: FontWeight.w800)),
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

  Widget _summaryRow(String label, String value, {Color valueColor = AppTheme.textMain}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textMuted,
            fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: valueColor)),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textMain),
      ),
    );
  }
}
