import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'colors.dart';

// Definimos los tipos de alerta para mayor control
enum alert_type { exito, error, advertencia }

Future mostrarAlerta(BuildContext context, {
required String title,
required String message,
required alert_type type
}) {
  
  // Configuración dinámica según el tipo
  String assetPath;
  Color colorIcono;

  switch (type) {
    case alert_type.exito:
      assetPath = 'assets/correcto.png'; // Aquí usas la palomita
      colorIcono = const Color.fromARGB(255, 48, 255, 75);
      break;
    case alert_type.error:
      assetPath = 'assets/error.png';      // Aquí usas la X
      colorIcono = Colors.redAccent;
      break;
    case alert_type.advertencia:
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                title.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorsecundario,
                    foregroundColor: colorWhite,
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
              if (type == alert_type.advertencia)...[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); 
                },
                child:  Text('Cancelar',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface),),
              ),
              ]
            ],
          ),
        ),
      );
    },
  );
}