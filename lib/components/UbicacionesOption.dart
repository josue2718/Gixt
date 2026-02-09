import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/components/colors.dart';

class UbicacionesOpciones extends StatelessWidget {
  final String calle;
  final String colonia;
  final String estado;
  final String ciudad;
  final String descripcion;
  final String id;

  const UbicacionesOpciones({
    super.key,
    required this.calle,
    required this.colonia,
    required this.estado,
    required this.ciudad,
    required this.descripcion,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ViewUbicacionPage(id_ubicacion: id),
        //   ),
        // );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorsecundario,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on, size: 30, color: colorWhite),
            ),

            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    calle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: colorsecundario,
                    ),
                  ),
                  Text(
                    '${colonia} ${estado} ${ciudad}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  Text(
                    descripcion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),

            InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ViewUbicacionPage(id_ubicacion: id),
                //   ),
                // );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: colorsecundario,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms).slideX(begin: -0.2);
  }
}
