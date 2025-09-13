// lib/widgets/custom_text_form_field.dart
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF0386D0),
          selectionColor: Color(0xFF0386D0).withValues(),
          selectionHandleColor: Color(0xFF0386D0),
        ),
      ),
      child: TextFormField(
        style: TextStyle(fontFamily: 'hind'),
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enableSuggestions: false,
        autocorrect: false,
        autofillHints: null,
        cursorColor: Color(0xFF0386D0),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Color(0xFFA6A6A6)),
          prefixIcon: Icon(prefixIcon, color: Color(0xFFA6A6A6)),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFA6A6A6),)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0386D0), width: 2)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
        ),
      ),
    );
  }
}