import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/colors.dart';

class CardsServicios extends StatelessWidget {
  const CardsServicios({super.key, required this.url_img, required this.nombre, required this.id_servicio,required this.img_trabajador, required this.trabajador, required this.categoria});

  final String nombre;
  final String url_img;
  final String id_servicio;
  final String? img_trabajador;
  final String categoria;
  final String trabajador;

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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: url_img,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: Indicador()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                       Positioned(
                        bottom: 120,
                        left: 10,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              height: 22,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                categoria,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorfondo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                shape: BoxShape.circle,
                                border: Border.all(color: colorWhite, width: 2),
                              ),
                              child: img_trabajador != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(img_trabajador!),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              height: 22,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                trabajador,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorfondo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),     
                  const SizedBox(height: 5),
                   const Divider(
                          color: colortitulo, 
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
                                  color: colortitulo,
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
                                  color: colortitulo,
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
