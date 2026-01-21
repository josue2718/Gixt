import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'colors.dart';

// Definimos los tipos de alerta para mayor control
enum TipoAlerta { exito, error, advertencia }

Future mostrarAlerta(BuildContext context, {
  required String titulo, 
  required String mensaje, 
  required TipoAlerta tipo
}) {
  
  // Configuración dinámica según el tipo
  String assetPath;
  Color colorIcono;

  switch (tipo) {
    case TipoAlerta.exito:
      assetPath = 'assets/correcto.png'; // Aquí usas la palomita
      colorIcono = const Color.fromARGB(255, 48, 255, 75);
      break;
    case TipoAlerta.error:
      assetPath = 'assets/error.png';      // Aquí usas la X
      colorIcono = Colors.redAccent;
      break;
    case TipoAlerta.advertencia:
      assetPath = 'assets/alerta.png'; // Aquí usas el signo !
      colorIcono = Colors.orangeAccent;
      break;
  }

  return showDialog(
    barrierDismissible: false, 
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: colorprimario,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // border: Border.all(color: colorWhite.withOpacity(0.5), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono con efecto de elevación suave
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colorIcono.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  assetPath,
                  width: 80, // Tamaño más equilibrado
                  height: 80,
                  // Si tus SVGs ya tienen color, quita la línea de abajo
                  // colorFilter: ColorFilter.mode(colorIcono, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: 20),
              Text(
                titulo.toUpperCase(),
                style: TextStyle(
                  color: colorWhite,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorWhite.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorWhite,
                    foregroundColor: colorprimario,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    "CONTINUAR",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  
                  onPressed: () =>  Navigator.pop(context, true),
                ),
                
              ),
              if (tipo == TipoAlerta.advertencia)...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); 
                },
                child: const Text('Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorWhite),),
              ),
              ]
            ],
          ),
        ),
      );
    },
  );
}