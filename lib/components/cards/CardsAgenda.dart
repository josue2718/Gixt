import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/pages/ViewAgendaPage.dart';
import 'package:gixt/services/reservas/Agenda_service.dart';
import 'package:google_fonts/google_fonts.dart';

class CardsAgenda extends StatelessWidget {
  const CardsAgenda({
    super.key,
   required this.image_url,
    required this.name,
    required this.job_id,
    required this.worker_image,
    required this.worker,
    required this.date,
    required this.time,
    required this.price,
    required this.description,
    required this.address,
    required this.status,
  });

  final String name;
  final String image_url;
  final String job_id;
  final String? worker_image;
  final String worker;
  final String description;
  final String address;
  final double price;
  final String date;
  final String status;
  final String time;

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.purple;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

 String _getStatusText() {
      switch (status.toLowerCase()) {
        case 'in_progress':
          return 'En Proceso';
        case 'accepted':
          return 'Aceptado';
        case 'pending':
          return 'Pendiente';
        case 'completed':
          return 'Completado';
        case 'canceled':
          return 'Cancelado';
        default:
          return status;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: SizedBox(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewAgendaPage(id_trabajo : job_id),
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
                          width: 120,
                          child: CachedNetworkImage(
                            imageUrl: image_url,
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
                            color: colorsecundario,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 15,
                                color:colorWhite,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  date,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 90,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 22,
                          decoration: BoxDecoration(
                            color: colorsecundario,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 15,
                                color: colorWhite,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  time,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                                image_url: worker_image,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  worker,
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

                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor().withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getStatusColor(),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            name,
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
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Footer: Dirección y Precio
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                           
                            ],
                          ),
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
