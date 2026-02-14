import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/pages/CategoriaPage.dart';

class Options extends StatelessWidget {
  final String name;
  final int id;
  final VoidCallback? onTap; // Añadido para manejar el clic

  const Options({
    super.key,
    required this.name,
    required this.id,
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
        child:  InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>CategoriaPage(category_id: id , name : name),
                ),
              );
            },
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenedor Circular (Estilo Rappi)
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color:  colorsecundario, // Fondo suave del mismo color
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.home_repair_service, // Tu icono original
                  size: 30,
                  color: colorWhite,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Texto descriptivo
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.surface, // Cambiado a oscuro para contraste sobre fondo claro
              ),
            ),
          ],
        ),
        )
      ),
    )
    .animate()
    .fade(duration: 400.ms)
    .scale(begin: const Offset(0.9, 0.9),);
  }
}