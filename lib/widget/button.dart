import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.buttonText = "Simpan",
    this.backgroundColor,
    this.textStyle,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: borderRadius!),
        ),
        child: Text(buttonText, style: textStyle?.copyWith(color: white)),
      ),
    );
  }
}



