import 'package:flutter/material.dart';
import 'package:gixt/Componets/colors.dart';

class CardsEmpresa extends StatelessWidget {
  const CardsEmpresa({super.key, required this.url_img, required this.nombre, required this.id_servicio});

  final String nombre;
  final String url_img;
  final String id_servicio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: SizedBox(
        width: 250, // 🔥 ANCHO FIJO OBLIGATORIO
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorprimario,
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => RestaurantePage(id_restaurante: id_servicio),
              //   ),
              // );
            },
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(0.0),
                    ),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Image.network(
                        url_img,
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (
                              BuildContext context,
                              Widget child,
                              ImageChunkEvent? loadingProgress,
                            ) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF670A0A),
                                ),
                              );
                            },
                        errorBuilder: (context, object, stackTrace) {
                          return const Icon(Icons.error);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                   const Divider(
                          color: colortitulo2, 
                          thickness: 2,
                          indent: 50, 
                          endIndent: 50, 
                        ),
                          const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colortitulo,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 7),

                            Row(
                              children: [
                                const Icon(
                                  Icons.groups_sharp,
                                  color: colortitulo2,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '\$100 a \$750 ',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: colortitulo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: colortitulo2,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '5 Estrellas',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: colortitulo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
