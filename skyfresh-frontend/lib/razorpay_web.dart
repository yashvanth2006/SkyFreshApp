import 'dart:html' as html;
import 'dart:js' as js;

class RazorpayWrapper {
  dynamic _razorpayInstance;
  
  RazorpayWrapper() {
    // Initialize Razorpay JS will be done when opening
  }
  
  void open(Map<String, dynamic> options) {
    try {
      // Convert options to JS object
      var jsOptions = js.JsObject.jsify({
        'key': options['key'],
        'amount': options['amount'],
        'name': options['name'],
        'description': options['description'],
        'prefill': options['prefill'],
        'theme': options['theme'],
        'handler': (response) {
          _handlePaymentSuccess(response);
        },
        'modal': {
          'ondismiss': () {
            _handlePaymentDismiss();
          }
        }
      });
      
      // Get Razorpay from window
      var razorpay = js.context['Razorpay'];
      if (razorpay != null) {
        _razorpayInstance = js.JsObject(razorpay, [jsOptions]);
        _razorpayInstance.callMethod('open');
      } else {
        print('Razorpay JS not loaded');
        _handlePaymentError('Razorpay not available');
      }
    } catch (e) {
      print('Error opening Razorpay: $e');
      _handlePaymentError(e.toString());
    }
  }
  
  void clear() {
    // No cleanup needed for web
  }
  
  void onPaymentSuccess(Function(dynamic) handler) {
    _paymentSuccessHandler = handler;
  }
  
  void onPaymentError(Function(String) handler) {
    _paymentErrorHandler = handler;
  }
  
  void onExternalWallet(Function(dynamic) handler) {
    _externalWalletHandler = handler;
  }
  
  Function(dynamic)? _paymentSuccessHandler;
  Function(String)? _paymentErrorHandler;
  Function(dynamic)? _externalWalletHandler;
  
  void _handlePaymentSuccess(dynamic response) {
    if (_paymentSuccessHandler != null) {
      _paymentSuccessHandler!(response);
    }
  }
  
  void _handlePaymentError(String error) {
    if (_paymentErrorHandler != null) {
      _paymentErrorHandler!(error);
    }
  }
  
  void _handlePaymentDismiss() {
    if (_paymentErrorHandler != null) {
      _paymentErrorHandler!('Payment cancelled');
    }
  }
}
