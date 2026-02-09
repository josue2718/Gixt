import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gixt/components/colors.dart';

class CustomTextFormFieldfecha extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool readOnly;

  const CustomTextFormFieldfecha({
    super.key,
    required this.controller,
    this.label = 'Fecha de nacimiento',
    this.hint = 'DD/MM/AAAA',
    this.icon = Icons.cake,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorBase = Theme.of(context).colorScheme.surface;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: TextInputType.number,
      style: TextStyle(color: colorBase),
      cursorColor: colorBase,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
        FechaNacimientoFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        // Label normal
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
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
        ),

        // 🔹 Línea cuando hay error
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
        ),

        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu fecha de nacimiento';
        }
        if (value.length != 10) {
          return 'Formato inválido (DD/MM/AAAA)';
        }
        return null;
      },
    );
  }
}

class FechaNacimientoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length > 8) return oldValue;

    String newText = text;

    if (text.length >= 5) {
      newText =
          '${text.substring(0, 2)}/${text.substring(2, 4)}/${text.substring(4)}';
    } else if (text.length >= 3) {
      newText = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
