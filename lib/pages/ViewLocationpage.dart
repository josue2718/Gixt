import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/Input.dart';
import 'package:gixt/components/inputs/Input_Description.dart';
import 'package:gixt/pages/UbicacionesPage.dart';
import 'package:gixt/services/ubicaciones/Ubicacionid_service.dart';
import 'package:gixt/services/ubicaciones/addubicacion_service.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewLocationPage extends StatefulWidget {
  const ViewLocationPage({super.key, required this.location_id});
  final String location_id;
  @override
  State<ViewLocationPage> createState() => _ViewLocationPageState();
}

class _ViewLocationPageState extends State<ViewLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _maps_addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _house_numberController = TextEditingController();

  final PageController _controller = PageController();
  final UbicacionesIdService ubicacion = UbicacionesIdService();
  double longitud = 0;
  double latitud = 0;
  int _paginaActual = 0;
  String? imagen;
  String? calle;
  String? ciudad;
  String? estado;
  GoogleMapController? mapController;
  LatLng? posicionActual = LatLng(20.9674, -89.5926);

  @override
  void initState() {
    super.initState();
    print("Entré a Mi Servicio");
    _initial();
  }

  Future<void> _initial() async {
    bool ok = await ubicacion.fetchData(widget.location_id);
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
    });
    bool ok = await ubicacion.fetchData(widget.location_id);
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
    if (ubicacion.ubicacion.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Indicador(),
      );
    }
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        floatingActionButton: _buttonDelete(context),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
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
                    const SizedBox(height: 10),
                    _buidFormularioInfo().animate().fade().slideX(begin: -0.2),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 70,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 70,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Theme.of(context).colorScheme.surface,
        onPressed: () {
          Navigator.pop(context); // sale de la pantalla
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mi Ubicación',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buidFormularioInfo() {
    latitud = ubicacion.ubicacion[0].latitude;
    longitud = ubicacion.ubicacion[0].longitude;
    imagen = ubicacion.ubicacion[0].image;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Título principal ──────────────────────────────
        Text(
          'Información del domicilio',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ).animate().fade(duration: 350.ms).slideY(begin: 0.1),

        const SizedBox(height: 24),

        // ── Dirección ─────────────────────────────────────
        Text(
          'Dirección',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ).animate().fade(duration: 350.ms, delay: 60.ms).slideX(begin: -0.08),

        const SizedBox(height: 8),

        _buidText(
          label: 'CALLE',
          value: ubicacion.ubicacion[0].street,
          icon: Icons.signpost_outlined,
        ).animate().fade(duration: 300.ms, delay: 80.ms).slideX(begin: -0.06),

        _buidText(
          label: 'COLONIA / FRACCIONAMIENTO',
          value: ubicacion.ubicacion[0].neighborhood,
          icon: Icons.holiday_village_outlined,
        ).animate().fade(duration: 300.ms, delay: 110.ms).slideX(begin: -0.06),

        _buidText(
          label: 'NÚMERO EXT / INT',
          value: ubicacion.ubicacion[0].house_number,
          icon: Icons.tag_outlined,
        ).animate().fade(duration: 300.ms, delay: 140.ms).slideX(begin: -0.06),

        _buidText(
          label: 'ESTADO',
          value: ubicacion.ubicacion[0].state,
          icon: Icons.map_outlined,
        ).animate().fade(duration: 300.ms, delay: 170.ms).slideX(begin: -0.06),

        _buidText(
          label: 'CIUDAD / MUNICIPIO',
          value: ubicacion.ubicacion[0].city,
          icon: Icons.location_city_outlined,
        ).animate().fade(duration: 300.ms, delay: 200.ms).slideX(begin: -0.06),

        const SizedBox(height: 20),

        // ── Referencias ───────────────────────────────────
        Text(
          'Referencias',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ).animate().fade(duration: 350.ms, delay: 230.ms).slideX(begin: -0.08),

        const SizedBox(height: 8),

        _buidText(
          label: 'REFERENCIAS ADICIONALES',
          value: ubicacion.ubicacion[0].reference,
          icon: Icons.info_outline_rounded,
        ).animate().fade(duration: 300.ms, delay: 250.ms).slideX(begin: -0.06),

        _buidText(
          label: 'DIRECCIÓN EN MAPS',
          value: ubicacion.ubicacion[0].maps_address,
          icon: Icons.place_outlined,
        ).animate().fade(duration: 300.ms, delay: 280.ms).slideX(begin: -0.06),

        const SizedBox(height: 20),

        // ── Foto ──────────────────────────────────────────
        Text(
          'Foto del domicilio',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
            letterSpacing: -0.2,
          ),
        ).animate().fade(duration: 350.ms, delay: 310.ms).slideX(begin: -0.08),

        const SizedBox(height: 14),

        _buidFormularioImg()
            .animate()
            .fade(duration: 400.ms, delay: 340.ms)
            .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOut),

        const SizedBox(height: 24),

        // ── Botón ─────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => abrirGoogleMaps(latitud, longitud),
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
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ).animate().fade(duration: 400.ms, delay: 380.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buidText({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.28),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 21),
            child: Text(
              value.isEmpty ? '—' : value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.55,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.08),
          ),
        ],
      ),
    );
  }

  Widget _buidFormularioImg() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          imagen == null
              ? Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 177, 177, 177),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 180,
                  width: double.infinity,
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
                  height: 200,
                  width: double.infinity,
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

  Widget _buttonDelete(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        print("Botón presionado");
      },
      backgroundColor: colorError,
      elevation: 6,
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
