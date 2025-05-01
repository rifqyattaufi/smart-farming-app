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
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.buttonText = "Simpan",
    this.backgroundColor,
    this.textStyle,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.isLoading = false,
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
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.0,
                ),
              )
            : Text(buttonText, style: textStyle?.copyWith(color: white)),
      ),
    );
  }
}
