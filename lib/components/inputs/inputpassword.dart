import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';

class CustomPasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const CustomPasswordFormField({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
    this.validator,
  });

  @override
  State<CustomPasswordFormField> createState() =>
      _CustomPasswordFormFieldState();
}

class _CustomPasswordFormFieldState extends State<CustomPasswordFormField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      style: TextStyle(color: Theme.of(context).colorScheme.surface),
      cursorColor: Theme.of(context).colorScheme.surface,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: widget.label,

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
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).colorScheme.surface,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),

        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.surface,
          fontWeight: FontWeight.bold,
        ),
      ),

      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese una contraseña';
            }
            return null;
          },
    );
  }
}
