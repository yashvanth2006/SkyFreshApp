void openRazorpayWebImpl({
  required String razorpayOrderId,
  required int amount,
  required String contact,
  required Function(String orderId, String paymentId, String signature) onSuccess,
  required Function() onDismiss,
  required Function(String error) onError,
}) {
  throw UnsupportedError('Razorpay Web is not supported on this platform.');
}
