import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/login/reset_password_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/otp.dart'; // Ensure this path is correct

class OtpScreen extends StatefulWidget {
  final String? email;

  const OtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<OTPInputWidgetState> _otpKey =
      GlobalKey<OTPInputWidgetState>();
  bool _isLoading = false;

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'email': widget.email,
      };

      final response = await _authService.resendOtp(data);
      if (response['status'] == true) {
        if (mounted) {
          showAppToast(
            context,
            'Kode OTP baru telah dikirim ke email ${widget.email}',
            isError: false,
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        // Handle error
        showAppToast(
            context, response['message'] ?? 'Gagal mengirim ulang kode OTP',
            isError: true);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkOtp(String otp) async {
    if (otp.length < 6) {
      showAppToast(
        context,
        'Kode OTP harus terdiri dari 6 digit',
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'email': widget.email,
        'otp': otp,
      };

      final response = await _authService.checkOtp(data);
      if (response['status'] == true) {
        context.push('/reset-password',
            extra: ResetPasswordScreen(email: widget.email, otp: otp));
      } else {
        showAppToast(
            context,
            response['message'] ??
                'Kode OTP tidak valid atau telah kedaluwarsa',
            isError: true);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/img-login.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Verifikasi Email',
                      style: bold20.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: regular14.copyWith(color: dark2),
                        children: [
                          const TextSpan(
                              text:
                                  'Masukkan 6 digit kode OTP yang dikirimkan ke email '),
                          TextSpan(
                            text: widget.email ?? 'Anda',
                            style: semibold14.copyWith(color: dark1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    OTPInputWidget(
                      key: _otpKey,
                      onResend: _isLoading
                          ? null
                          : _resendOtp, // Disable resend while loading
                      onSubmit: (otp) {
                        if (!_isLoading) {
                          // Prevent multiple submissions
                          _checkOtp(otp);
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            buttonText: 'Verifikasi',
            onPressed: _isLoading
                ? null
                : () {
                    // Disable button while loading
                    final otp = _otpKey.currentState?.getOtp() ?? '';
                    _checkOtp(otp);
                  },
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isLoading,
            key: const Key('verify_button'),
          ),
        ),
      ),
    );
  }
}
