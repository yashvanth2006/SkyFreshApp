import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/screens/checkout_screen.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/widgets/animated_pressable.dart';
import 'package:skyfresh/widgets/premium_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _placingOrder = false;

Future<void> _startCheckout(CartProvider cart, int subtotal, int deliveryFee, int grandTotal) async {
    // Prevent multiple taps
    if (_placingOrder) return; 
    
    setState(() => _placingOrder = true);

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

    // Reset the loading state when the user returns to the cart
    if (mounted) {
      setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final deliveryFee = cart.items.isEmpty ? 0 : (cart.totalPrice >= 500 ? 0 : 50);
    final grandTotal = cart.totalPrice + deliveryFee;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My Cart',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5, color: AppTheme.textMain)),
                  if (cart.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('${cart.totalItems} items',
                        style: const TextStyle(color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w800, fontSize: 13)),
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
                          width: 100, height: 100,
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceMuted,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.shopping_cart_outlined, size: 48, color: AppTheme.textMuted)),
                        ),
                        const SizedBox(height: 24),
                        const Text('Your cart is empty',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                              letterSpacing: -0.3, color: AppTheme.textMain)),
                        const SizedBox(height: 8),
                        const Text('Add some premium fruits & juices!',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Dismissible(
                        key: ValueKey('${item.name}-${item.weight}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => context.read<CartProvider>()
                            .removeItem(item.name, item.weight),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.only(right: 24),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [AppTheme.cardShadow],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(16)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: PremiumImage(
                                    imageUrl: item.image,
                                    fallbackUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=400&auto=format&fit=crop',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                      style: const TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                          color: AppTheme.textMain)),
                                    const SizedBox(height: 4),
                                    Text(item.weight,
                                      style: const TextStyle(fontSize: 13,
                                          color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text('₹${item.total}',
                                      style: const TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryDark)),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24, offset: const Offset(0, -8))],
                ),
                child: Column(
                  children: [
                    _summaryRow('Subtotal', '₹${cart.totalPrice}'),
                    const SizedBox(height: 12),
                    _summaryRow(
                      'Delivery Fee',
                      deliveryFee == 0 ? 'FREE' : '₹$deliveryFee',
                      valueColor: deliveryFee == 0 ? AppTheme.primaryDark : AppTheme.textMain,
                    ),
                    if (deliveryFee > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping_rounded, color: AppTheme.primaryDark, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Add ₹${500 - cart.totalPrice} more for free delivery',
                                style: const TextStyle(fontSize: 13, color: AppTheme.primaryDark,
                                    fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppTheme.border, height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                              color: AppTheme.textMain)),
                        Text('₹$grandTotal',
                          style: const TextStyle(fontSize: 28,
                              fontWeight: FontWeight.w800, letterSpacing: -0.5,
                              color: AppTheme.textMain)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    AnimatedPressable(
                      onTap: _placingOrder
                        ? null
                        : () => _startCheckout(cart, cart.totalPrice, deliveryFee, grandTotal),
                      child: Container(
                        width: double.infinity, height: 60,
                        decoration: BoxDecoration(
                          gradient: _placingOrder ? null : AppTheme.greenGradient,
                          color: _placingOrder ? AppTheme.surfaceLight : null,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _placingOrder ? [] : [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Center(
                          child: _placingOrder
                            ? const SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3))
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
        Text(label, style: const TextStyle(fontSize: 15, color: AppTheme.textMuted,
            fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
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
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 18, color: AppTheme.textMain),
      ),
    );
  }
}
