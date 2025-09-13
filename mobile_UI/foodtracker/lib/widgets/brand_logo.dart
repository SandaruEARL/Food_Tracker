// lib/widgets/brand_logo.dart
import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double? fontSize;
  final double? size;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;
  final bool showVersion;
  final String? customVersion;

  const BrandLogo({
    super.key,
    this.fontSize,
    this.size,
    this.alignment = MainAxisAlignment.center,
    this.padding,
    this.showVersion = false,
    this.customVersion,
  });

  @override
  Widget build(BuildContext context) {

    final effectiveFontSize = size ?? fontSize ?? 18.0;

    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: alignment,
            children: [
              Text(
                "SPEED ",
                style: TextStyle(
                  fontSize: effectiveFontSize,
                  fontFamily: 'hind',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0386D0),
                ),
              ),
              Text(
                "MAN",
                style: TextStyle(
                  fontSize: effectiveFontSize,
                  fontFamily: 'hind',
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}