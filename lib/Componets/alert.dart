import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'colors.dart';

// Función reusable para mostrar alerta con imagen centrada
Future mostrarAlerta(BuildContext context, String titulo, String mensaje) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: colorfondo1,
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           SvgPicture.asset(
          'assets/logo.svg',
          width: 300,
          height: 300,
          color: colorWhite,
        ),
            SizedBox(height: 20),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorprimario,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              "OK",
              style: TextStyle(color: Color(0xFF2D5F3F)),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
