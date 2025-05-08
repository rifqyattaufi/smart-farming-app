import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class InputFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InputFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    bool isTextEmpty = controller.text.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: semibold14.copyWith(color: dark1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: obscureText && isTextEmpty ? '● ● ● ● ● ● ● ●' : hint,
            hintStyle: medium14.copyWith(color: grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixIconTap,
                    child: suffixIcon,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
