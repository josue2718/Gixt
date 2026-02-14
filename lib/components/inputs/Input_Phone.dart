import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gixt/components/colors.dart';

class CustomTextFormFieldPhone extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFormFieldPhone({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.keyboardType = TextInputType.phone,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorBase = Theme.of(context).colorScheme.surface;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: 10,
      style: TextStyle(color: colorBase),
      cursorColor: colorBase,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        labelText: label,

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
        suffixIcon: Icon(Icons.phone, color: colorBase),

        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontWeight: FontWeight.bold,
        ),
      ),
      validator: validator,
    );
  }
}



class PhoneDashFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length <= 3) {
      return newValue.copyWith(text: digits);
    } else if (digits.length <= 6) {
      return newValue.copyWith(
        text: '${digits.substring(0, 3)}-${digits.substring(3)}',
      );
    } else {
      return newValue.copyWith(
        text:
            '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, digits.length)}',
      );
    }
  }
}
