import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.readOnly,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(color: Theme.of(context).colorScheme.surface),
      cursorColor: Theme.of(context).colorScheme.surface,
      decoration: InputDecoration(
        labelText: label,

        // 🔹 Label normal
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.surface),

        // 🔹 Label cuando está seleccionado
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontWeight: FontWeight.bold,
        ),

        border: const UnderlineInputBorder(),

        // 🔹 Línea normal
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
        ),

        // 🔹 Línea cuando está seleccionado
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2),
        ),

        // 🔹 Línea cuando hay error
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
        ),

        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2),
        ),

        // 🔹 Ícono
        suffixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.surface, // siempre secundario
        ),

        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontWeight: FontWeight.bold,
        ),
      ),
      validator: validator,
    );
  }
}
