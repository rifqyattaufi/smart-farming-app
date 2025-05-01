// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response['status'] == true) {
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
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
          // Scroll jika keyboard naik
          child: Column(
            children: [
              Image.asset(
                'assets/images/img-login.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputFieldWidget(
                        label: "Email pengguna",
                        hint: "Contoh: example@mail.com",
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      InputFieldWidget(
                        label: "Masukkan Password",
                        hint: "Contoh: password",
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        suffixIcon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onSuffixIconTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            // Action lupa password
                          },
                          child: Text(
                            'Lupa password?',
                            style: regular14.copyWith(color: green1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              onPressed: _login,
                              buttonText: 'Masuk',
                              backgroundColor: green1,
                              textStyle: semibold16,
                              textColor: white,
                            ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'atau',
                            style: medium14.copyWith(color: dark1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Action login Google
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: green1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/google.svg',
                            width: 24,
                            height: 24,
                          ),
                          label: Text(
                            'Lanjutkan dengan Google',
                            style: semibold16.copyWith(color: green1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
