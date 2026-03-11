import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool autofocus;
  final bool readOnly;
  final TextStyle? style;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.autofocus = false,
    this.readOnly = false,
    this.style,
    this.validator,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      autofocus: autofocus,
      readOnly: readOnly,
      style: style,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}
