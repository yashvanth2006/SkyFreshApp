import 'dart:js' as js;

void openRazorpayWebImpl({
  required String razorpayOrderId,
  required int amount,
  required String contact,
  required Function(String orderId, String paymentId, String signature) onSuccess,
  required Function() onDismiss,
  required Function(String error) onError,
}) {
  try {
    var options = js.JsObject.jsify({
      'key': 'rzp_test_TEbkIK2Vtv3aJO',
      'order_id': razorpayOrderId,
      'amount': amount,
      'name': 'SKYfresh',
      'description': 'Fresh fruits and juices',
      'prefill': {
        'contact': contact,
        'email': '',
      },
      'theme': {
        'color': '#4CAF50'
      },
      'handler': (response) {
        onSuccess(
          response['razorpay_order_id']?.toString() ?? '', 
          response['razorpay_payment_id']?.toString() ?? '', 
          response['razorpay_signature']?.toString() ?? ''
        );
      },
      'modal': {
        'ondismiss': () {
          onDismiss();
        }
      }
    });

    // Call Razorpay via JS
    var razorpay = js.context['Razorpay'];
    if (razorpay != null) {
      var razorpayWebInstance = js.JsObject(razorpay, [options]);
      razorpayWebInstance.callMethod('open');
    } else {
      onError('Razorpay JS not loaded');
    }
  } catch (e) {
    onError(e.toString());
  }
}
