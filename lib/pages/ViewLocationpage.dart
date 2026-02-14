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
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder(
          future: Future.wait([]),
          builder: (context, snapshot) {
            if (ubicacion.ubicacion.isEmpty) {
              return Indicador();
            }
            return KeyboardDismisser(
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 10),
                            _buidFormularioInfo().animate().fade().slideX(
                              begin: -0.2,
                            ),
                            const SizedBox(height: 30),
                            // _bu().animate().fade().slideX(begin: -0.2),
                            //  const SizedBox(height: 10),
                            // _buidFormularioInfo().animate().fade().slideX(begin: -0.2),
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
      backgroundColor: colorprimario,
      expandedHeight: 90,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 90,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context); // sale de la pantalla
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mi Ubicación',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }

  Widget _buidFormularioInfo() {
    _streetController.text = ubicacion.ubicacion[0].street;
    _neighborhoodController.text = ubicacion.ubicacion[0].neighborhood;
    _house_numberController.text = ubicacion.ubicacion[0].house_number;
    _stateController.text = ubicacion.ubicacion[0].state;
    _cityController.text = ubicacion.ubicacion[0].city;
    _referenceController.text = ubicacion.ubicacion[0].reference;
    _maps_addressController.text = ubicacion.ubicacion[0].maps_address;

    latitud = ubicacion.ubicacion[0].latitude;
    longitud = ubicacion.ubicacion[0].longitude;
    imagen = ubicacion.ubicacion[0].image;

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informacion del domicilio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 30),

            /// CALLE
            CustomTextFormField(
              controller: _streetController,
              label: 'Calle e intersecciónes',
              icon: Icons.home,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una calle';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// COLONIA
            CustomTextFormField(
              controller: _neighborhoodController,
              label: 'Colonia o Fraccionamiento',
              icon: Icons.apartment,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una colonia o fraccionamiento';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// NUMERO CASA
            CustomTextFormField(
              controller: _house_numberController,
              label: 'Numero Exterior y/o Interior',
              icon: Icons.apartment,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el número de casa';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// ESTADO
            CustomTextFormField(
              controller: _stateController,
              label: 'Estado',
              icon: Icons.apartment,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su estado';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// CIUDAD
            CustomTextFormField(
              controller: _cityController,
              label: 'Ciudad o Municipio',
              icon: Icons.apartment,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su ciudad';
                }
                return null;
              },
            ),

            const SizedBox(height: 30),

            CustomDescriptionFormField(
              controller: _referenceController,
              minLines: 2,
              maxLines: 4,
              label: 'Referencias adicionales',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor descripcion';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// MAPS
            TextFormField(
              controller: _maps_addressController,
              readOnly: true,
              minLines: 2,
              maxLines: 2,
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
              decoration: InputDecoration(
                labelText: 'Direccion maps',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                suffixIcon: Icon(
                  Icons.map,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              'Archivos adjuntos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 20),
            _buidFormularioImg(),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                abrirGoogleMaps(latitud, longitud);
              },
              icon: const Icon(Icons.map, color: colorWhite),
              label: const Text(
                'Ver en Google Maps',
                style: TextStyle(fontSize: 18, color: colorWhite),
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
    );
  }

  Widget _buidFormularioImg() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
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
                        placeholder: (context, url) =>
                            Center(child: Indicador()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
