import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormFieldNumber extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final IconData icon;
  final String? Function(String?)? validator;

  const CustomTextFormFieldNumber({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorBase = Theme.of(context).colorScheme.surface;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: colorBase,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      cursorColor: colorBase,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
        suffixIcon: Icon(icon, color: colorBase),

        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontWeight: FontWeight.bold,
        ),
        // Hint con formato de ejemplo
        hintText: '0',
        hintStyle: TextStyle(
          color: colorBase.withOpacity(0.35),
          fontSize: 16,
        ),

       

        // Sufijo con la moneda (puedes cambiar MXN/USD según tu app)
        suffix: Text(
          'Minutos',
          style: TextStyle(
            color: colorBase.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),

        counterText: '', // Oculta el contador de caracteres

      ),
      validator: validator,
    );
  }
}


/// Formateador que agrega separadores de miles y mantiene 2 decimales
class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Permitir borrar
    if (text.isEmpty) return newValue;

    // Solo permitir dígitos y un punto decimal
    final regex = RegExp(r'^\d+\.?\d{0,2}$');
    if (!regex.hasMatch(text)) return oldValue;

    return newValue;
  }
}