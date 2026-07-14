import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/ApiService.dart';
import 'package:skyfresh/screens/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int subtotal;
  final int deliveryFee;
  final int grandTotal;
  const CheckoutScreen({super.key, required this.subtotal, required this.deliveryFee, required this.grandTotal});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');

  bool _placing = false;
  String _paymentMethod = 'COD';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _houseCtrl.dispose();
    _streetCtrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  String _buildAddress() {
    final parts = [
      _houseCtrl.text,
      _streetCtrl.text,
      _landmarkCtrl.text,
      _cityCtrl.text,
      _stateCtrl.text,
      _pinCtrl.text,
      _countryCtrl.text,
    ];
    return parts.where((p) => p.trim().isNotEmpty).join(', ');
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() => _placing = true);

    final items = cart.items.map((i) => {
      'name': i.name,
      'price': i.priceInt,
      'quantity': i.quantity,
      'unit': i.unit,
      'emoji': i.emoji,
    }).toList();

    final address = _buildAddress();

    final res = await ApiService.placeOrder(
      items: items,
      subtotal: widget.subtotal,
      deliveryFee: widget.deliveryFee,
      total: widget.grandTotal,
      address: address,
      paymentMethod: _paymentMethod,
    );

    setState(() => _placing = false);
    if (!mounted) return;

    if (res['success'] == true) {
      final orderId = res['orderId'] ?? res['id'] ?? '';
      cart.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Could not place order')));
    }
  }

  Widget _stepIndicator() {
    final steps = ['Cart', 'Address', 'Payment', 'Review'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (i) {
        final isActive = i <= 1; // Address step active
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted)), Text('₹${widget.subtotal}'),]),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Checkout', style: TextStyle(color: AppTheme.textMain)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stepIndicator(),
              const SizedBox(height: 18),

              // Address Form
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full Name *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter full name' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Mobile Number *'),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter mobile number';
                          final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleaned.length < 10) return 'Enter valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _altPhoneCtrl,
                        decoration: const InputDecoration(labelText: 'Alternate Mobile Number (optional)'),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
                          if (cleaned.length < 10) return 'Enter valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _houseCtrl,
                        decoration: const InputDecoration(labelText: 'House / Flat Number *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter house/flat number' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _streetCtrl,
                        decoration: const InputDecoration(labelText: 'Street / Area *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter street/area' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _landmarkCtrl,
                        decoration: const InputDecoration(labelText: 'Landmark (optional)'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(labelText: 'City *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stateCtrl,
                        decoration: const InputDecoration(labelText: 'State *'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter state' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pinCtrl,
                        decoration: const InputDecoration(labelText: 'Pincode *'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter pincode';
                            if (!RegExp(r'^\d+$').hasMatch(v.trim())) return 'Pincode should be numeric';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _countryCtrl,
                        decoration: const InputDecoration(labelText: 'Country'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                    const SizedBox(height: 12),
                    ...cart.items.map((i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text(i.emoji, style: const TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text('x${i.quantity}  ', style: const TextStyle(color: AppTheme.textMuted)),
                          Text('₹${i.total}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted)), Text('₹${""}'),]),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Delivery Charge', style: TextStyle(color: AppTheme.textMuted)), Text(widget.deliveryFee == 0 ? 'FREE' : '₹${widget.deliveryFee}')]),
                    const SizedBox(height: 10),
                    Divider(color: AppTheme.border),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)), Text('₹${widget.grandTotal}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))]),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Payment Methods
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _paymentMethod = 'COD'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'COD' ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _paymentMethod == 'COD' ? AppTheme.primary : AppTheme.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.currency_rupee_rounded, color: AppTheme.primary),
                            SizedBox(width: 12),
                            Expanded(child: Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.w700))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: null,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.payment_rounded, color: AppTheme.textMuted),
                            SizedBox(width: 12),
                            Expanded(child: Text('Google Pay / Razorpay', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textMuted))),
                            Text('Coming Soon', style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _placing ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _placing ? const CircularProgressIndicator(color: Colors.white) : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
