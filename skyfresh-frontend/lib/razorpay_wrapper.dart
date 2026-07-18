import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayWrapper {
  Razorpay _razorpay = Razorpay();
  
  RazorpayWrapper() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void open(Map<String, dynamic> options) {
    _razorpay.open(options);
  }
  
  void clear() {
    _razorpay.clear();
  }
  
  void onPaymentSuccess(Function(PaymentSuccessResponse) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handler);
  }
  
  void onPaymentError(Function(PaymentFailureResponse) handler) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handler);
  }
  
  void onExternalWallet(Function(ExternalWalletResponse) handler) {
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handler);
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handler will be set by the screen
  }
  
  void _handlePaymentError(PaymentFailureResponse response) {
    // Handler will be set by the screen
  }
  
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handler will be set by the screen
  }
}
