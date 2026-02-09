import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';

class CustomTextFormFieldTime extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final VoidCallback? onTap; // 👈 NUEVO

  const CustomTextFormFieldTime({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.readOnly,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onTap, // 👈 NUEVO
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap, // 👈 AQUÍ
      style: TextStyle(
        color: Theme.of(context).colorScheme.surface,
      ),
      cursorColor: Theme.of(context).colorScheme.surface,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
        ),
        border: const UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        suffixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.surface,
        ),
        errorStyle: const TextStyle(
          color: colorsecundario,
          fontWeight: FontWeight.bold,
        ),
      ),
      validator: validator,
    );
  }
}
