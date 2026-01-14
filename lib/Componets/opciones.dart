import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/colors.dart';


class Options extends StatelessWidget {
  // final Function(int) onEspecialidadSelected;
  final String nombre;

  const Options({
    super.key,
    // required this.onEspecialidadSelected,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
          return Card(
                elevation: 1,
                color: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  // onTap: () => onEspecialidadSelected(empresa.id_categoria),
                  // onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CategoriasPage()),
                  //   );
                  // },
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20),
                        Container(
                          padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                        child: 
                        const Icon(
                          Icons.room_service,
                          size: 36,
                          color: colorprimario,
                        ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .fade(duration: 400.ms)
              .slideY(begin: 0.15)
              .scale(begin: const Offset(0.96, 0.96));
  }
}
