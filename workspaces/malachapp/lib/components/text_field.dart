import 'package:flutter/material.dart';

/// A custom text field widget.
///
/// This widget provides a customizable text field with an optional hint text
/// and an optional obscure text mode. It also requires a [TextEditingController]
/// to control the text input.
class MyTextField extends StatelessWidget {
  final String hintText;
  final bool? obscureText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  /// Creates a new instance of [MyTextField].
  ///
  /// The [hintText] parameter specifies the hint text to display in the text field.
  /// The [obscureText] parameter determines whether the text should be obscured
  /// (e.g., for password input). The [controller] parameter is required to control
  /// the text input.
  const MyTextField({
    super.key,
    required this.hintText,
    this.obscureText,
    required this.controller,
    this.keyboardType,
    this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText ?? false,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: hintText,
      ),
    );
  }
}
