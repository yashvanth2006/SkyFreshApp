import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';
import 'package:skyfresh/screens/order_success_screen.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:js' as js;

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

  late Razorpay _razorpay;
  dynamic _razorpayWebInstance;
  bool _placing = false;
  bool _processingPayment = false;
  bool _addressesLoading = true;
  List<UserAddress> _savedAddresses = const [];
  UserAddress? _selectedAddress;
  String _paymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Web: Razorpay JS will be initialized when needed
    } else {
      // Mobile: Initialize Razorpay Flutter plugin
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
    _loadSavedAddresses();
  }

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
    if (!kIsWeb) {
      _razorpay.clear();
    }
    super.dispose();
  }

  Future<void> _loadSavedAddresses() async {
    final profile = await ApiService.getProfile();
    if (!mounted) return;
    setState(() {
      _savedAddresses = profile?.addresses ?? const [];
      _selectedAddress = _savedAddresses.isEmpty
          ? null
          : _savedAddresses.firstWhere(
              (address) => address.isDefault,
              orElse: () => _savedAddresses.first,
            );
      _addressesLoading = false;
    });
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() => _processingPayment = false);
    
    if (response.orderId == null || response.paymentId == null || response.signature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed: Missing payment details')),
      );
      return;
    }
    
    _verifyAndPlaceOrder(response.orderId!, response.paymentId!, response.signature!);
  }

  void _handlePaymentSuccessWeb(dynamic response) {
    final orderId = response['razorpay_order_id']?.toString();
    final paymentId = response['razorpay_payment_id']?.toString();
    final signature = response['razorpay_signature']?.toString();
    
    if (orderId == null || paymentId == null || signature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment verification failed: Missing payment details')),
      );
      return;
    }
    
    _verifyAndPlaceOrder(orderId, paymentId, signature);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _processingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.code} - ${response.message}')),
    );
  }

  void _handlePaymentErrorWeb(String error) {
    setState(() => _processingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $error')),
    );
  }

  Future<void> _verifyAndPlaceOrder(String orderId, String paymentId, String signature) async {
    setState(() => _processingPayment = true);

    // Step 2: Verify payment with backend
    final verifyRes = await ApiService.verifyPayment(orderId, paymentId, signature);

    if (!mounted) return;

    if (verifyRes['success'] != true) {
      setState(() => _processingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(verifyRes['message'] ?? 'Payment verification failed')),
      );
      return;
    }

    // Step 3: Place order with payment status
    await _placeOrder();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  void _openRazorpay() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    if (_savedAddresses.isEmpty && !_formKey.currentState!.validate()) return;

    setState(() => _processingPayment = true);

    // Step 1: Create Razorpay order on backend
    final orderRes = await ApiService.createRazorpayOrder(widget.grandTotal.toDouble());
    
    if (!mounted) return;
    
    if (orderRes['success'] != true) {
      setState(() => _processingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderRes['message'] ?? 'Failed to create payment order')),
      );
      return;
    }

    final razorpayOrderId = orderRes['order']['id'];

    if (kIsWeb) {
      _openRazorpayWeb(razorpayOrderId);
    } else {
      _openRazorpayMobile(razorpayOrderId);
    }
  }

  void _openRazorpayMobile(String razorpayOrderId) {
    var options = {
      'key': 'rzp_test_TEbkIK2Vtv3aJO',
      'order_id': razorpayOrderId,
      'amount': widget.grandTotal * 100,
      'name': 'SKYfresh',
      'description': 'Fresh fruits and juices',
      'prefill': {
        'contact': _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '',
        'email': '',
      },
      'external': {
        'wallets': ['paytm']
      },
      'modal': {
        'confirm_close': true,
        'escape': true,
      },
      'theme': {
        'color': '#4CAF50'
      }
    };

    try {
      print('Opening Razorpay Mobile with options: $options');
      _razorpay.open(options);
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && _processingPayment) {
          setState(() => _processingPayment = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment timeout. Please try again.')),
          );
        }
      });
    } catch (e) {
      print('Error opening Razorpay Mobile: $e');
      setState(() => _processingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening Razorpay: $e')),
      );
    }
  }

  void _openRazorpayWeb(String razorpayOrderId) {
    try {
      var options = js.JsObject.jsify({
        'key': 'rzp_test_TEbkIK2Vtv3aJO',
        'order_id': razorpayOrderId,
        'amount': widget.grandTotal * 100,
        'name': 'SKYfresh',
        'description': 'Fresh fruits and juices',
        'prefill': {
          'contact': _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '',
          'email': '',
        },
        'theme': {
          'color': '#4CAF50'
        },
        'handler': (response) {
          print('Payment success: $response');
          _verifyAndPlaceOrder(response['razorpay_order_id'], response['razorpay_payment_id'], response['razorpay_signature']);
        },
        'modal': {
          'ondismiss': () {
            print('Payment modal dismissed');
            setState(() => _processingPayment = false);
          }
        }
      });

      // Call Razorpay via JS
      var razorpay = js.context['Razorpay'];
      if (razorpay != null) {
        _razorpayWebInstance = js.JsObject(razorpay, [options]);
        _razorpayWebInstance.callMethod('open');
        
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && _processingPayment) {
            setState(() => _processingPayment = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment timeout. Please try again.')),
            );
          }
        });
      } else {
        print('Razorpay JS not loaded');
        setState(() => _processingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Razorpay not available. Please try again.')),
        );
      }
    } catch (e) {
      print('Error opening Razorpay Web: $e');
      setState(() => _processingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening Razorpay: $e')),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_savedAddresses.isEmpty && !_formKey.currentState!.validate()) return;
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
      'unit': i.weight,
      'emoji': i.emoji,
    }).toList();

    final address = _selectedAddress?.line ?? _buildAddress();

    final res = await ApiService.placeOrder(
      items: items,
      subtotal: widget.subtotal,
      deliveryCharge: widget.deliveryFee,
      totalAmount: widget.grandTotal,
      shippingAddress: address,
      paymentMethod: _paymentMethod,
    );

    setState(() => _placing = false);
    setState(() => _processingPayment = false);
    if (!mounted) return;

    if (res['success'] == true) {
      final orderId = res['orderId']?.toString() ?? res['order']?['_id']?.toString() ?? '';
      cart.clearCart();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId.toString())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Could not place order')));
    }
  }

  Widget _deliveryAddressSection() {
    if (_addressesLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_savedAddresses.isEmpty) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
            const SizedBox(height: 12),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter full name' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Number *'), keyboardType: TextInputType.phone, validator: (v) => (v == null || v.trim().replaceAll(RegExp(r'[^0-9]'), '').length < 10) ? 'Enter valid phone number' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _houseCtrl, decoration: const InputDecoration(labelText: 'House / Flat Number *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter house/flat number' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _streetCtrl, decoration: const InputDecoration(labelText: 'Street / Area *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter street/area' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _stateCtrl, decoration: const InputDecoration(labelText: 'State *'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter state' : null),
            const SizedBox(height: 8),
            TextFormField(controller: _pinCtrl, decoration: const InputDecoration(labelText: 'Pincode *'), keyboardType: TextInputType.number, validator: (v) => (v == null || !RegExp(r'^\d+$').hasMatch(v.trim())) ? 'Enter numeric pincode' : null),
          ],
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Select saved address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
      const SizedBox(height: 8),
      ..._savedAddresses.map((address) => RadioListTile<UserAddress>(
        value: address,
        groupValue: _selectedAddress,
        onChanged: (value) => setState(() => _selectedAddress = value),
        contentPadding: EdgeInsets.zero,
        title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(address.line),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
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
              // Address Form
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: _deliveryAddressSection(),
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
                          Expanded(child: Text('${i.name} (${i.weight})', style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text('x${i.quantity}  ', style: const TextStyle(color: AppTheme.textMuted)),
                          Text('₹${i.total}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted)), Text('₹${widget.subtotal}')]),
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
                      onTap: () => setState(() => _paymentMethod = 'Razorpay'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'Razorpay' ? AppTheme.primary.withOpacity(0.12) : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _paymentMethod == 'Razorpay' ? AppTheme.primary : AppTheme.border),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.payment_rounded, color: AppTheme.primary),
                            SizedBox(width: 12),
                            Expanded(child: Text('Razorpay', style: TextStyle(fontWeight: FontWeight.w700))),
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
                  onPressed: (_placing || _processingPayment) ? null : () {
                    if (_paymentMethod == 'Razorpay') {
                      _openRazorpay();
                    } else {
                      _placeOrder();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _placing || _processingPayment ? const CircularProgressIndicator(color: Colors.white) : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
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