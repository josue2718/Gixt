import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';

class CustomDescriptionFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;

  const CustomDescriptionFormField({
    super.key,
    required this.controller,
    this.label = 'Descripción del problema',
    this.icon = Icons.description,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.multiline,
      minLines: minLines,
      maxLines: maxLines,
      style:  TextStyle(color:  Theme.of(context).colorScheme.surface),
      cursorColor:  Theme.of(context).colorScheme.surface,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:  TextStyle(color:  Theme.of(context).colorScheme.surface),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color:  Theme.of(context).colorScheme.surface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color:  Theme.of(context).colorScheme.surface, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color:  Theme.of(context).colorScheme.surface),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(color:  Theme.of(context).colorScheme.surface),
        ),
        errorStyle: const TextStyle(
          color: colorsecundario,
          fontWeight: FontWeight.bold,
        ),
        suffixIcon: Icon(icon, color:  Theme.of(context).colorScheme.surface),
      ),
      
    );
  }
}
