import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/pages/categoria.dart'; // Asegúrate que 'colorprimario' esté definido aquí

class UbicacionesOpcion extends StatelessWidget {
  final String calle;
  final String colonia;
  final String estado;
  final String ciudad;
  final String descripcion;
  final String id;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const UbicacionesOpcion({
    super.key,
    required this.calle,
    required this.colonia,
    required this.estado,
    required this.ciudad,
    required this.descripcion,
    required this.id,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorprimario,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorWhite,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on,size: 30, color: colorprimario),
            ),

            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    calle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorWhite,
                    ),
                  ),
                  Text(
                    '${colonia} ${estado} ${ciudad}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorWhite,
                    ),
                  ),
                  Text(
                    descripcion,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorWhite,
                    ),
                  ),
                ],
              ),
            ),
           
             Radio<String>(
              value: id,
              groupValue: selectedId,
              activeColor: colorWhite,
              onChanged: (value) {
                print(value);
                if (value != null) onSelected(value);
              },
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms).slideX(begin: -0.2);
  }
}
