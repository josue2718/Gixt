import 'package:flutter/material.dart';

Future<void> selectTime({
  required BuildContext context,
  required TextEditingController controller,
}) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 8, minute: 0),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: false),
        child: child ?? const SizedBox(),
      );
    },
  );

  if (picked != null) {
    if (picked.hour < 8 || picked.hour >= 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccione un horario entre 8:00 AM y 12:00 PM',
          ),
        ),
      );
      return;
    }
    final String formattedTime =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    controller.text = formattedTime;
  }
}
