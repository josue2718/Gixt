import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/colors.dart'; // Asegúrate que 'colorprimario' esté definido aquí

class Options extends StatelessWidget {
  final String nombre;
  final VoidCallback? onTap; // Añadido para manejar el clic

  const Options({
    super.key,
    required this.nombre,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
        // color: colorWhite,
        width: 15, // Ancho fijo para mantener simetría en listas horizontales
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor Circular (Estilo Rappi)
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: colorWhite, // Fondo suave del mismo color
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorprimario.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.home_repair_service, // Tu icono original
                  size: 30,
                  color: colorprimario,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Texto descriptivo
            Text(
              nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorWhite, // Cambiado a oscuro para contraste sobre fondo claro
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fade(duration: 400.ms)
    .scale(begin: const Offset(0.9, 0.9),);
  }
}