import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';
import 'package:skyfresh/screens/order_success_screen.dart';
import 'package:skyfresh/widgets/animated_pressable.dart';
import 'package:skyfresh/widgets/premium_image.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razorpay_stub.dart' if (dart.library.js) 'razorpay_web.dart';

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

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _processingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.code} - ${response.message}')),
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
    openRazorpayWebImpl(
      razorpayOrderId: razorpayOrderId,
      amount: widget.grandTotal * 100,
      contact: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '',
      onSuccess: (orderId, paymentId, signature) {
        print('Payment success: orderId=$orderId');
        _verifyAndPlaceOrder(orderId, paymentId, signature);
      },
      onDismiss: () {
        print('Payment modal dismissed');
        setState(() => _processingPayment = false);
      },
      onError: (error) {
        print('Error opening Razorpay Web: $error');
        setState(() => _processingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening Razorpay: $error')),
        );
      },
    );
    
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _processingPayment) {
        setState(() => _processingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment timeout. Please try again.')),
        );
      }
    });
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
            const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
            const SizedBox(height: 16),
            _buildTextField(_nameCtrl, 'Full Name *', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _buildTextField(_phoneCtrl, 'Mobile Number *', Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildTextField(_houseCtrl, 'House / Flat Number *', Icons.home_outlined),
            const SizedBox(height: 12),
            _buildTextField(_streetCtrl, 'Street / Area *', Icons.map_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_cityCtrl, 'City *', Icons.location_city_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_stateCtrl, 'State *', Icons.map_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(_pinCtrl, 'Pincode *', Icons.pin_drop_outlined, keyboardType: TextInputType.number),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
            Icon(Icons.edit_location_alt_outlined, color: AppTheme.primaryDark),
          ],
        ),
        const SizedBox(height: 16),
        ..._savedAddresses.map((address) {
          final isSelected = _selectedAddress == address;
          return GestureDetector(
            onTap: () => setState(() => _selectedAddress = address),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryLight.withValues(alpha: 0.3) : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border.withValues(alpha: 0.5), width: isSelected ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isSelected ? AppTheme.primaryDark : AppTheme.textMain)),
                        const SizedBox(height: 4),
                        Text(address.line, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.border.withValues(alpha: 0.4))),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        if (label.contains('Mobile') && v.trim().replaceAll(RegExp(r'[^0-9]'), '').length < 10) return 'Invalid phone';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Checkout', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: _deliveryAddressSection(),
              ),

              const SizedBox(height: 24),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
                    const SizedBox(height: 16),
                    ...cart.items.map((i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(14)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: PremiumImage(
                                imageUrl: i.image,
                                fallbackUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=400&auto=format&fit=crop',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${i.name} (${i.weight})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('x${i.quantity}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Text('₹${i.total}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        ],
                      ),
                    )),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w500)), Text('₹${widget.subtotal}', style: const TextStyle(fontWeight: FontWeight.w700))]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Delivery', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w500)), Text(widget.deliveryFee == 0 ? 'FREE' : '₹${widget.deliveryFee}', style: TextStyle(color: widget.deliveryFee == 0 ? AppTheme.primaryDark : AppTheme.textMain, fontWeight: FontWeight.w700))]),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.primaryLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Grand Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)), Text('₹${widget.grandTotal}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryDark))]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Methods
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [AppTheme.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
                    const SizedBox(height: 16),
                    AnimatedPressable(
                      onTap: () => setState(() => _paymentMethod = 'COD'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'COD' ? AppTheme.primaryLight.withValues(alpha: 0.3) : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _paymentMethod == 'COD' ? AppTheme.primary : AppTheme.border.withValues(alpha: 0.5), width: _paymentMethod == 'COD' ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.currency_rupee_rounded, color: AppTheme.primaryDark, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                            if (_paymentMethod == 'COD') const Icon(Icons.check_circle_rounded, color: AppTheme.primaryDark),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedPressable(
                      onTap: () => setState(() => _paymentMethod = 'Razorpay'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _paymentMethod == 'Razorpay' ? AppTheme.primaryLight.withValues(alpha: 0.3) : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _paymentMethod == 'Razorpay' ? AppTheme.primary : AppTheme.border.withValues(alpha: 0.5), width: _paymentMethod == 'Razorpay' ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.credit_card_rounded, color: AppTheme.primaryDark, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: Text('Razorpay (Cards / UPI)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                            if (_paymentMethod == 'Razorpay') const Icon(Icons.check_circle_rounded, color: AppTheme.primaryDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Place Order Button
              AnimatedPressable(
                onTap: (_placing || _processingPayment) ? null : () {
                  if (_paymentMethod == 'Razorpay') {
                    _openRazorpay();
                  } else {
                    _placeOrder();
                  }
                },
                child: Container(
                  width: double.infinity, height: 64,
                  decoration: BoxDecoration(
                    gradient: (_placing || _processingPayment) ? null : AppTheme.greenGradient,
                    color: (_placing || _processingPayment) ? AppTheme.surfaceMuted : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: (_placing || _processingPayment) ? [] : [
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Center(
                    child: _placing || _processingPayment 
                      ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3)) 
                      : const Text('Place Order', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
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