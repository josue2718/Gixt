import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/pages/ServicioPage.dart';
import 'package:google_fonts/google_fonts.dart';

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
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color:  Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServicioPage(id_servicio: id_servicio),
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
                          bottomLeft: Radius.circular(20),
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
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorsecundario,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            categoria,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                              Expanded(
                                child: Text(
                                  trabajador,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const Spacer(),
                          Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$estrellas',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: colorfondo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Descripción
                          Text(
                            descripcion,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                          const Spacer(),

                          // Footer: Precio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colorsecundario,
                                  borderRadius: BorderRadius.circular(14),
                                 
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '\$',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.surface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      precio.toStringAsFixed(2),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.surface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
