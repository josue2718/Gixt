import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/inputs/pick_image.dart';
import 'package:gixt/pages/UbicacionesPage.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
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


class ViewUbicacionPage extends StatefulWidget {
  const ViewUbicacionPage({super.key, required this.id_ubicacion});
  final String id_ubicacion;
  @override
  State<ViewUbicacionPage> createState() => _ViewUbicacionPageState();
}

class _ViewUbicacionPageState extends State<ViewUbicacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _descripcionmapsController = TextEditingController();
  final _estadoController = TextEditingController();
  final _ncasaController = TextEditingController();
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
  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
     ubicacion.fetchData(widget.id_ubicacion);
    });
  }


  // void _Crear() async {
  //   if (posicionActual == null && ciudad == null) {
  //     mostrarAlerta(
  //       context,
  //       titulo: 'Ubicacion requerida',
  //       mensaje: 'Por favor selecciona una imagen de perfil',
  //       tipo: TipoAlerta.advertencia,
  //     );
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => Indicador(),
  //   );

  //   final result = await AddUbicacionService.Crear(

  //     ciudad: _ciudadController.text,
  //     longitud: longitud,
  //     latitud: latitud , 
  //     calle: _calleController.text, 
  //     colonia: _coloniaController.text,
  //      ncasa: _ncasaController.text, 
  //      estado: _estadoController.text,
  //       referencias: _descripcionController.text, 
  //       image: _image!,
  //       direccion_maps : '${calle} ${ciudad} ${estado}'

  //   );

  //   Navigator.pop(context);

  //   if (result['success'] == true) {
      
  //     Future.microtask(() async {
  //       await mostrarAlerta(
  //         context,
  //         titulo: "Operacion exitosa",
  //         mensaje: 'ubicacion añadida',
  //         tipo: TipoAlerta.exito,
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => UbicacionesPage()),
  //       );
  //     });
  //   } else {
  //     mostrarAlerta(
  //       context,
  //       titulo: "Error",
  //       mensaje: result['message'],
  //       tipo: TipoAlerta.error,
  //     );
  //   }
  // }

Future<void> abrirGoogleMaps(double lat, double lng) async {
  final Uri googleMapsUri = Uri.parse(
    "geo:$lat,$lng?q=$lat,$lng"
  );

  if (await launchUrl(
    googleMapsUri,
    mode: LaunchMode.externalApplication,
  )) {
    return;
  }

  final Uri webUrl = Uri.parse(
    "https://www.google.com/maps/search/?api=1&query=$lat,$lng"
  );

  if (!await launchUrl(
    webUrl,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'No se pudo abrir Google Maps';
  }
}



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    ubicacion.fetchData(widget.id_ubicacion);
  }

  void initState() {
    super.initState();
    // 👇 SE EJECUTA AL ENTRR A LA PÁGINA
    print("Entré a ver ubicacion by id");
    ubicacion.fetchData(widget.id_ubicacion);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: FutureBuilder(
          future: Future.wait([ ubicacion.fetchData(widget.id_ubicacion)]),
          builder: (context, snapshot) {
            if (ubicacion.ubicacion.isEmpty) {
              return Indicador();
            }
            return KeyboardDismisser(
              child: Scaffold(
                backgroundColor: colorfondo,
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
                            _buidFormularioInfo().animate().fade().slideX(begin: -0.2), 
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mi Ubicación',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }
 
  Widget _buidFormularioInfo() {
    final screenHeight = MediaQuery.of(context).size.height;
    _calleController.text = ubicacion.ubicacion[0].calle;
    _coloniaController.text = ubicacion.ubicacion[0].colonia;
    _ncasaController.text =ubicacion.ubicacion[0].ncasa;
    _estadoController.text = ubicacion.ubicacion[0].estado;
    _ciudadController.text = ubicacion.ubicacion[0].ciudad;
    _descripcionController.text = ubicacion.ubicacion[0].referencias;
    _descripcionmapsController.text = ubicacion.ubicacion[0].direccionMaps;
    latitud = ubicacion.ubicacion[0].latitud;
    longitud = ubicacion.ubicacion[0].longitud;
    imagen = ubicacion.ubicacion[0].urlImg;
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Informacion del domicilio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _calleController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Calle e intersecciónes',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.home, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una calle';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _coloniaController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Colonia o Fraccionamiento',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.apartment, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una colonia o fraccionamiento';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _ncasaController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Numero Exterior y/o Interior',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.apartment, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el problema';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _estadoController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Estado',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.apartment, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su estado ';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _ciudadController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Ciudad o Municipio',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.apartment, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el problema';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _descripcionController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              keyboardType: TextInputType.multiline,
              minLines: 4,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Referencias adicionales',
                labelStyle: const TextStyle(color: colorWhite),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // cuadrado suave
                  borderSide: const BorderSide(color: colorWhite),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: colorWhite, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                suffixIcon: const Icon(Icons.description, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la descripción del problema';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descripcionmapsController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              readOnly: true,
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Direccion maps',
                labelStyle: const TextStyle(color: colorWhite),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // cuadrado suave
                  borderSide: const BorderSide(color: colorWhite),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: colorWhite, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                suffixIcon: const Icon(Icons.description, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese la descripción del problema';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archivos adjuntos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            SizedBox(height: 20),
            _buidFormularioImg(),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                abrirGoogleMaps(latitud, longitud);
              },
              icon: const Icon(Icons.map),
              label: const Text(
                'Ver en Google Maps',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorWhite,
                foregroundColor: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // if (!(_formKey.currentState?.validate() ?? false)) return;
                // if (_image == null) {
                //   mostrarAlerta(
                //     context,
                //     titulo: 'Imagen requerida',
                //     mensaje: 'Por favor llena los 3 campos de imagen',
                //     tipo: TipoAlerta.advertencia,
                //   );
                //   return;
                // }

                // setState(() {
                //   _paginaActual++;
                // });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorWhite,
                foregroundColor: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Eliminar', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buidFormularioUbicacion() {
    final h = MediaQuery.of(context).size.height;

    return SizedBox(
      height: h,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: posicionActual!,
              zoom: 16,
            ),

            myLocationEnabled: true,
            myLocationButtonEnabled: true,

            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            
            markers: {
              Marker(
                markerId: MarkerId("ubicacion"),
                position: posicionActual!,
              ),
            },
          ),
          
            
          
        ],
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
