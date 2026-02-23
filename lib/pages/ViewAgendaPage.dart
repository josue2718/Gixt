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
import 'package:gixt/pages/ViewLocation.dart';
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
    if (agenda.agenda.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Indicador(),
      );
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
        bottomNavigationBar: _bottomBar(context),
      ),
      
    );
  }

  SliverAppBar _buildSliverAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
      expandedHeight: 320,
      pinned: false,
      floating: false, //  sin efecto raro
      snap: false, //  sin delay
      elevation: 0,
      toolbarHeight: 90,
      iconTheme: IconThemeData(color: colorWhite),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const SizedBox(), //  quitamos title para evitar desplazamientos
        background: Stack(
          fit: StackFit.expand,
          children: [
            ///  IMAGEN
            CachedNetworkImage(
              imageUrl: agenda.agenda[0].service_image,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: Indicador()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ),

            Container(color: Colors.black.withOpacity(isDark ? 0.35 : 0.15)),

            Positioned(
              bottom: 5,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NOMBRE
                  Text(
                    agenda.agenda[0].service_name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorWhite,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        _buildTitle()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        Barstatus(
              estadoTrabajo: agenda.agenda[0].job_status.isEmpty
                  ? ''
                  : agenda.agenda[0].job_status,
            )
            .animate()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        _buildTrabajo()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        _buildWorker()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        _buildServicio()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        _buildImg()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
        _buildUbicacion()
            .animate()
            .fade(duration: 450.ms, delay: 60.ms)
            .slideX(begin: -0.2),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 13, color: colorsecundario),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            agenda.agenda[0].maps_address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.event_outlined,
          size: 13,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.35),
        ),
        const SizedBox(width: 3),
        Text(
          agenda.agenda[0].job_date,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.access_time_outlined,
          size: 13,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.35),
        ),
        const SizedBox(width: 3),
        Text(
          agenda.agenda[0].job_time,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget imageBox(String? imagen) {
    return SizedBox(
      width: 100,
      height: 130,
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

  Widget _buildWorker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trabajador',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Circleimage(
                w: 56,
                h: 56,
                image_url: agenda.agenda[0].worker_image,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            agenda.agenda[0].worker_username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                        const SizedBox(width: 3),
                        Text(
                          '${agenda.agenda[0].worker_rating}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      agenda.agenda[0].worker_description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.6,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.45),
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
        Text(
          'Servicio solicitado:   ${agenda.agenda[0].service_name}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),

        const SizedBox(height: 10),
        Text(
          '${agenda.agenda[0].service_description}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.75,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
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
        Text(
          'Problema a resolver',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '${agenda.agenda[0].problem}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.75,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
          ),
        ),

        SizedBox(height: 20),
        Text(
          'Descripción',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '${agenda.agenda[0].description}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.75,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
          ),
        ),
        SizedBox(height: 20),

        Text(
          'Pago y Metodo',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ),

        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Precio',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.55),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    '${agenda.agenda[0].price == 0 ? "Pendiente" : agenda.agenda[0].price}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,

                      color: Theme.of(context).colorScheme.surface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Metodo',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.55),
                    ),
                  ),

                  SizedBox(height: 10),
                  Text(
                    '${agenda.agenda[0].payment_method}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,

                      color: Theme.of(context).colorScheme.surface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
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
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.surface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
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
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.75,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      '${agenda.agenda[0].state} ${agenda.agenda[0].neighborhood} ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.75,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.55),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          abrirGoogleMaps(agenda.agenda[0].latitude, agenda.agenda[0].longitude);
                        },
                        icon: const Icon(
                          Icons.directions_rounded,
                          color: colorWhite,
                          size: 20,
                        ),
                        label: Text(
                          'Cómo llegar',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colorWhite,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: colorsecundario,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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

  Widget _buildImg() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(height: 20),
            Text(
              'Imagenes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.surface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              imageBox(agenda.agenda[0].image_1),
              const SizedBox(width: 20),
              imageBox(agenda.agenda[0].image_2),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(BuildContext context) {
    final jobStatus = agenda.agenda[0].job_status.toLowerCase();

    IconData icon = Icons.info;
    String text = '';
    VoidCallback? action;
    Color bgColor = colorsecundario;

    switch (jobStatus) {
      case 'pending':
        icon = Icons.hourglass_empty;
        text = 'Pendiente';
        action = null;
        bgColor = Theme.of(context).colorScheme.surface.withOpacity(0.6);
        break;

      case 'accepted':
        icon = Icons.check_circle;
        text = 'Aceptado';
        action = null;
        break;

      case 'going':
      case 'arrived':
      case 'in_progress':
        icon = Icons.map;
        text = 'Ver ubicación';
        action = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLocationTimePage(
                job_id: widget.id_trabajo,
                latitude: agenda.agenda[0].latitude,
                longitude: agenda.agenda[0].longitude,
              ),
            ),
          );
        };
        break;

      case 'finalized':
        icon = Icons.payment;
        text = 'Pagar';
        action = () {
          print('pagar');
        };
        break;
      case 'completed':
        icon = Icons.payment;
        text = 'ver registro de pago';
        action = () {
          print('pagar');
        };
        break;
      default:
        icon = Icons.help;
        text = jobStatus;
        action = null;
        bgColor = Theme.of(context).colorScheme.surface.withOpacity(0.6);
    }

    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: action,
        icon: Icon(icon, color: colorWhite),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, color: colorWhite),
        ),
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 50),
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    final jobStatus = agenda.agenda[0].job_status.toLowerCase();

    IconData icon = Icons.info;
    String text = '';
    VoidCallback? action;
    Color bgColor = colorsecundario;

    switch (jobStatus) {
      case 'pending':
        icon = Icons.hourglass_empty;
        text = 'Pendiente';
        action = null;
        bgColor = Theme.of(context).colorScheme.surface.withOpacity(0.6);
        break;

      case 'accepted':
        icon = Icons.check_circle;
        text = 'Aceptado';
        action = null;
        break;

      case 'going':
      case 'arrived':
      case 'in_progress':
        icon = Icons.map;
        text = 'Ver ubicación';
        action = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewLocationTimePage(
                job_id: widget.id_trabajo,
                latitude: agenda.agenda[0].latitude,
                longitude: agenda.agenda[0].longitude,
              ),
            ),
          );
        };
        break;

      case 'finalized':
        icon = Icons.payment;
        text = 'Pagar';
        action = () {
          print('pagar');
        };
        break;
      case 'completed':
        icon = Icons.payment;
        text = 'ver registro de pago';
        action = () {
          print('pagar');
        };
        break;
      default:
        icon = Icons.help;
        text = jobStatus;
        action = null;
        bgColor = Theme.of(context).colorScheme.surface.withOpacity(0.6);
    }

    return ElevatedButton.icon(
      onPressed: action,
      icon: Icon(icon, color: colorWhite),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: colorWhite),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 50),
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
