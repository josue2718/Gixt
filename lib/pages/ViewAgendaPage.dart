import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/BarStatus.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/circleimage.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/services/reservas/Agenda_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewAgendaPage extends StatefulWidget {
  const ViewAgendaPage({super.key, required this.id_trabajo});
  final String id_trabajo;
  @override
  State<ViewAgendaPage> createState() => _ViewAgendaPageState();
}

class _ViewAgendaPageState extends State<ViewAgendaPage> {
  bool isLoading = false;
  bool hasMore = true;
  final AgendaById_service agenda = AgendaById_service();
  final ScrollController _scrollController = ScrollController();
  final PreferencesService _preferencesService = PreferencesService();
  @override
  void initState() {
    super.initState();
    print("Entré a Mi Servicio");
    _initial();
  }

  Future<void> _initial() async {
    bool ok = await agenda.fetchServicioData(widget.id_trabajo);
    if (!ok) {
      if (!mounted) return;
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Error",
          message: "No se pudo obtener la información",
          type: alert_type.error,
        );

        Navigator.pop(context);
      });
    }

    setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      hasMore = true;
    });
    bool ok = await agenda.fetchServicioData(widget.id_trabajo);
    if (!ok) {
      if (!mounted) return;
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Error",
          message: "No se pudo obtener la información",
          type: alert_type.error,
        );

        Navigator.pop(context);
      });
    }
    setState(() {});
  }

  Future<void> abrirGoogleMaps(double lat, double lng) async {
    final Uri googleMapsUri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");

    if (await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication)) {
      return;
    }

    final Uri webUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );

    if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([]),
          builder: (context, snapshot) {
            if (agenda.agenda.isEmpty) {
              return Indicador();
            }
            return KeyboardDismisser(
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildInformacion(),
                               
                            const SizedBox(height: 40),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 90,
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 90,

      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.surface, // 👈 color del ícono
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Agenda',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildInformacion() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '¡Informacion de la reserva!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(height: 20),
              Barstatus(estadoTrabajo: agenda.agenda[0].job_status).animate().fade().slideX(begin: -0.2,),
              SizedBox(height: 20),
              _buildTrabajador() .animate().fade().slideX(begin: -0.2,),
              SizedBox(height: 20),
              _buildServicio().animate().fade().slideX(begin: -0.2,),
              SizedBox(height: 20),
              _buildTrabajo() .animate().fade().slideX(begin: -0.2,),
              SizedBox(height: 20),
              _buildImg().animate().fade().slideX(begin: -0.2,),
              SizedBox(height: 20),
              _buildUbicacion() .animate().fade().slideX(begin: -0.2,),
              SizedBox(height: 20),
              _buildPrecio().animate().fade().slideX(begin: -0.2,),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(300, 50),
              backgroundColor: colorsecundario,
              foregroundColor: colorWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Eliminar', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget imageBox(String? imagen) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,

        children: [
          imagen == null
              ? Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 177, 177, 177),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 200,
                  height: 200,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.person,
                    ), // Usa un icono de calendario
                    color: const Color.fromARGB(255, 255, 255, 255),
                    iconSize: 65,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(0, 103, 10, 10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 200,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: imagen!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: Indicador()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTrabajador() {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Trabajador',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Circleimage(
                w: 80,
                h: 80,
                image_url: agenda.agenda[0].worker_image,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                        child: Text(
                          agenda.agenda[0].worker_username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorWhite.withOpacity(0.95),
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
                                '${agenda.agenda[0].worker_rating}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: colorBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agenda.agenda[0].worker_description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServicio() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Servicio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '${agenda.agenda[0].service_name}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${agenda.agenda[0].service_description}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrabajo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Trabajo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.home_repair_service,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descripcion ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),

              Text(
                '${agenda.agenda[0].description}',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(height: 20),

              Text(
                'Fecha del servicio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${agenda.agenda[0].job_date}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${agenda.agenda[0].job_time}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUbicacion() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Ubicacion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.location_on,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              imageBox(agenda.agenda[0].location_image),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${agenda.agenda[0].maps_address}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    Text(
                      '${agenda.agenda[0].state} ${agenda.agenda[0].neighborhood} ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        abrirGoogleMaps(agenda.agenda[0].latitude, agenda.agenda[0].longitude);
                      },
                      icon: const Icon(Icons.map, color: colorWhite),
                      label: const Text(
                        'Ver',
                        style: TextStyle(fontSize: 15, color: colorWhite),
                      ),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 50),
                        backgroundColor: colorsecundario,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrecio() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Pago y Metodo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.payment,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),

                    SizedBox(height: 20),
                    Container(
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
                        '${agenda.agenda[0].price}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorWhite,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Metodo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),

                    SizedBox(height: 20),
                    Container(
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
                        '${agenda.agenda[0].payment_method}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorWhite,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImg() {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Imagenes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            Spacer(),
            Icon(
              Icons.photo,
              size: 25,
              color: Theme.of(context).colorScheme.surface,
            ),
          ],
        ),
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: [
              imageBox(agenda.agenda[0].image_1),
              const SizedBox(width: 20),
              imageBox(agenda.agenda[0].image_2),
              const SizedBox(width: 10),
            ],
          ),
          )
        ),
      ],
    );
  }

}
