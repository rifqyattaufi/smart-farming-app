import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:flutter/gestures.dart';

class OTPInputWidget extends StatefulWidget {
  final List<String>? prefilledDigits;

  const OTPInputWidget({super.key, this.prefilledDigits});

  @override
  State<OTPInputWidget> createState() => _OTPInputWidgetState();
}

class _OTPInputWidgetState extends State<OTPInputWidget> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late Timer _timer;
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
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var ctrl in _controllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 55,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: widget.prefilledDigits == null,
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: green1, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: green1, width: 2.4),
          ),
        ),
        style: bold20.copyWith(
          color: dark1,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_otpLength, (index) => _buildOTPBox(index))
              .expand(
                (widget) => [widget, const SizedBox(width: 8)],
              )
              .toList()
            ..removeLast(),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: RichText(
            text: TextSpan(
              style: semibold14.copyWith(color: green1, height: 2),
              children: [
                TextSpan(
                  text: 'Kirim Ulang',
                  style: semibold14.copyWith(
                    decoration: TextDecoration.underline,
                    decorationThickness: 2,
                    decorationColor: green1,
                    color: green1,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                TextSpan(
                  text:
                      ' dalam 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
