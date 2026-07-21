import 'package:flutter/material.dart';
import '../api_service.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit verification code'),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Call verification logic
    final response = await ApiService.verifyOtp(widget.phone, otp);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account verified! Welcome to SKYfresh 🌿'),
        ),
      );

      // Route authorized user straight into core storefront shell
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Invalid OTP code'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'We sent a verification code to\n+91 ${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            _isVerifying
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Verify & Continue'),
                  ),
          ],
        ),
      ),
    );
  }
}