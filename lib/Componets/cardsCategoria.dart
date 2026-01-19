import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/circleimage.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/pages/serviciopage.dart';

class CardsServiciosCategoria extends StatelessWidget {
  const CardsServiciosCategoria({
    super.key,
    required this.url_img,
    required this.nombre,
    required this.id_servicio,
    required this.img_trabajador,
    required this.trabajador,
    required this.categoria,
    required this.precio,
    required this.descripcion,
    required this.estrellas,
  });

  final String nombre;
  final String url_img;
  final String id_servicio;
  final String? img_trabajador;
  final String categoria;
  final String trabajador;
  final int estrellas;
  final String descripcion;
  final double precio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: SizedBox(
        width: 150, // 🔥 ANCHO FIJO OBLIGATORIO
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: colorprimario,
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServicioPage(id_servicio: id_servicio ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
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
                          height: double.maxFinite,
                          width: 150,
                          child: CachedNetworkImage(
                            imageUrl: url_img,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: Indicador()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 120,
                        left: 10,
                        child: Container(
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
                      ),
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Circleimage(
                                w: 30,
                                h: 30,
                                link_imagen: img_trabajador,
                              ),
                              const SizedBox(width: 10),
                               Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
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
                              
                              const Spacer(),
                              const Icon(
                                Icons.star_rounded,
                                color: colortitulo,
                                size: 25,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$estrellas',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: colortitulo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                         
                          Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colortitulo,
                                ),
                          ),
                          
                          const SizedBox(height: 7),
                          Text(
                            'Precio: \$ $precio',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: colortitulo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: colortitulo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
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
