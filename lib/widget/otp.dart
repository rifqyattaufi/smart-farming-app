import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:flutter/gestures.dart';

class OTPInputWidget extends StatefulWidget {
  final List<String>? prefilledDigits;
  final VoidCallback? onResend;
  final void Function(String otp)? onSubmit;

  const OTPInputWidget({
    super.key,
    this.prefilledDigits,
    this.onResend,
    this.onSubmit,
  });

  @override
  OTPInputWidgetState createState() => OTPInputWidgetState();
}

class OTPInputWidgetState extends State<OTPInputWidget> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  Timer? _timer;
  int _secondsRemaining = 50;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _otpLength,
      (index) => TextEditingController(
        text: widget.prefilledDigits != null &&
                index < widget.prefilledDigits!.length
            ? widget.prefilledDigits![index]
            : '',
      ),
    );
    _focusNodes = List.generate(_otpLength, (index) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _secondsRemaining = 50; // Reset seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _handleOtpChange(String value, int index) {
    // 'value' is the new text in the TextField.
    // _controllers[index].text is already updated to 'value' by the TextField
    // before this onChanged callback is fired.

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        // Move to next field, defer to avoid race conditions
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          }
        });
      } else {
        // Last field filled, unfocus to hide keyboard or allow submission
        _focusNodes[index].unfocus();
      }
    } else {
      // Character was deleted, so 'value' is empty
      if (index > 0) {
        // If a character is deleted and the field becomes empty, move focus to the previous field.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        });
      }
    }

    // Check if all fields are filled to trigger onSubmit
    // This should be checked after any change (addition or deletion).
    final String currentOtp = getOtp();
    if (currentOtp.length == _otpLength && widget.onSubmit != null) {
      widget.onSubmit!(currentOtp);
    }
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 50, // Adjusted for better spacing
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: widget.prefilledDigits == null,
        decoration: InputDecoration(
          counterText: '', // Hide the default counter
          contentPadding:
              EdgeInsets.zero, // Adjust padding to center text if needed
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: green1.withOpacity(0.5), width: 1.2),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: green1, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: bold20.copyWith(color: dark1),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          // Handle paste scenario more explicitly if needed,
          // though single char paste will be handled by the logic above.
          // For multi-character paste, you might need a custom paste handler
          // or rely on the user pasting into the first box and it auto-filling.
          // The current _handleOtpChange assumes 'value' is the content of the *current* box.
          _handleOtpChange(value, index);
        },
        onTap: () {
          // Select all text on tap for easier editing/replacement
          _controllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controllers[index].text.length,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribute boxes evenly
          children: List.generate(_otpLength, (index) => _buildOTPBox(index)),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: RichText(
            text: TextSpan(
              style: semibold14.copyWith(color: dark2, height: 1.5),
              children: [
                if (_secondsRemaining == 0)
                  TextSpan(
                    text: 'Kirim Ulang Kode',
                    style: semibold14.copyWith(
                      decoration: TextDecoration.underline,
                      color: green1,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (widget.onResend != null) {
                          widget.onResend!();
                          _startTimer(); // Restart timer
                        }
                      },
                  )
                else
                  TextSpan(
                    text:
                        'Kirim ulang dalam 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
