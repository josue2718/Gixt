import 'package:flutter/material.dart';
import 'package:gixt/components/colors.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> selectTime({
  required BuildContext context,
  required TextEditingController controller,
}) async {
final TimeOfDay? picked = await showTimePicker(
  context: context,
  initialTime: const TimeOfDay(hour: 8, minute: 0),

  helpText: 'Enter time',
  cancelText: 'Cancel',
  confirmText: 'OK',

  builder: (context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        timePickerTheme: TimePickerThemeData(

          // Fondo general del picker
          backgroundColor: Colors.white,

          //  Texto de la hora y minutos seleccionados (números grandes)
          hourMinuteTextColor: Colors.black,

          //  Fondo del cuadro de hora y minutos
          hourMinuteColor: Colors.grey.shade200,

          //  Color de la manecilla del reloj
          dialHandColor: Colors.black,

          //  Fondo del reloj circular
          dialBackgroundColor: Colors.grey.shade200,

          //  Icono para cambiar modo reloj / teclado
          entryModeIconColor: Colors.black,

          //  Texto AM / PM
          dayPeriodTextColor: Colors.white,

          //  Fondo del botón AM / PM seleccionado
          dayPeriodColor: Colors.black,

          //  Texto superior "Enter time"
          helpTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),

          //  Números dentro del reloj circular
          dialTextColor: Colors.black,

          //  Bordes del contenedor hora/minutos
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          //  Bordes del selector AM / PM
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        //  Botones OK y Cancel
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
      ),
      child: child!,
    );
  },
);



  if (picked != null) {
    if (picked.hour < 8 || picked.hour >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        
        SnackBar(
          backgroundColor: colorprimario,
          content: Text(
            'Seleccione un horario entre 8:00 AM y 10:00 PM',
             style: TextStyle(
              color:  colorWhite,
            ),
          ),
        ),
      );
      return;
    }

    // FORMATO 12 HORAS (AM/PM)
    final String formattedTime = picked.format(context);

    controller.text = formattedTime;
  }
}
