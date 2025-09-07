// lib/widgets/custom_elevated_button.dart
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? elevation;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF0386D0),
    this.foregroundColor = Colors.white,
    this.width = double.infinity,
    this.height = 50,
    this.borderRadius = 10,
    this.elevation = 2,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        minimumSize: Size(width ?? double.infinity, height ?? 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
        ),
        elevation: elevation,
      ),
      child: isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: foregroundColor,
          strokeWidth: 2,
        ),
      )
          : Text(
        text,
        style: textStyle ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}