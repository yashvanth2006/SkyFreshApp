import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/screens/home_screen.dart';


class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  bool _loading = false;

  Future<void> _verify() async {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
        content: const Text('Please enter all 6 digits', style: TextStyle(color: Colors.white))));
      return;
    }

    setState(() => _loading = true);

    final result = await ApiService.verifyOtp(
      phone: widget.phone,
      otp: _otp,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryDark,
        content: const Text('Welcome to SKYfresh! 🌿', style: TextStyle(color: Colors.white))));
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(result['message'] ?? 'Invalid OTP', style: const TextStyle(color: Colors.white))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 74, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border)
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 8),
                        Text('SKYfresh',
                          style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Verify Number',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.1,
                        letterSpacing: -1.2, color: AppTheme.textMain)),
                  const SizedBox(height: 12),
                  Text('Code sent to ${widget.phone}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 15,
                        fontWeight: FontWeight.w500, height: 1.6)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border)),
                    child: const Text('Enter the 6-digit code sent to your phone',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMain, fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 32),

                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (v) => _otp = v,
                    onCompleted: (_) => _verify(),
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.scale,
                    cursorColor: AppTheme.primary,
                    textStyle: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(14),
                      fieldHeight: 60,
                      fieldWidth: 50,
                      activeFillColor: AppTheme.surfaceLight,
                      selectedFillColor: AppTheme.surfaceLight,
                      inactiveFillColor: AppTheme.surfaceLight,
                      activeColor: AppTheme.primary,
                      selectedColor: AppTheme.primary,
                      inactiveColor: AppTheme.border,
                    ),
                    enableActiveFill: true,
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: _loading ? null : _verify,
                    child: Container(
                      width: double.infinity, height: 60,
                      decoration: BoxDecoration(
                        gradient: _loading ? null : AppTheme.greenGradient,
                        color: _loading ? AppTheme.surfaceLight : null,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: _loading ? [] : [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 20, offset: const Offset(0, 8)
                          )
                        ],
                      ),
                      child: Center(
                        child: _loading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5))
                          : const Text('Verify OTP',
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  RichText(
                    text: const TextSpan(
                      text: "Didn't receive the code? ",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                      children: [
                        TextSpan(text: 'Resend',
                          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                      ],
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
}