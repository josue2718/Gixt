import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/Input.dart';
import 'package:gixt/components/inputs/Input_Description.dart';
import 'package:gixt/components/inputs/Pick_Image.dart';
import 'package:gixt/pages/UbicacionesPage.dart';
import 'package:gixt/services/ubicaciones/addubicacion_service.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class AddUbicacionPage extends StatefulWidget {
  const AddUbicacionPage({super.key});
  @override
  State<AddUbicacionPage> createState() => _AddUbicacionPageState();
}

class _AddUbicacionPageState extends State<AddUbicacionPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _maps_addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _house_numberController = TextEditingController();
  final PageController _controller = PageController();
  double longitude = 0;
  double latitude = 0;
  int _paginaActual = 0;
  File? _image;
  String? calle;
  String? ciudad;
  String? estado;
  GoogleMapController? mapController;
  LatLng? posicionActual = LatLng(20.9674, -89.5926);

  Future<void> _irAMiUbicacion() async {
    final position = await Geolocator.getCurrentPosition();
    final nuevaPos = LatLng(position.latitude, position.longitude);

    setState(() {
      posicionActual = nuevaPos;
      latitude = position.latitude;
      longitude = position.longitude;
    });
    getcalle();
  }

  void getcalle() {
    GeocodingHelper.obtenerCiudadDesdeCoordenadas(
      latitud: latitude,
      longitud: longitude,
      onResult: (ciudadResult, calleResult, estadoResult) {
        setState(() {
          ciudad = ciudadResult;
          calle = calleResult;
          estado = estadoResult;
          print(calle);
        });
      },
    );
  }

  void obtenerCoordenadas() async {
    try {
      Position pos = await LocationService.obtenerUbicacion();
      latitude = pos.latitude;
      longitude = pos.longitude;
      setState(() {
        posicionActual = LatLng(pos.latitude, pos.longitude);
      });
      getcalle();
    } catch (e) {
      print(e);
    }
  }

  void _Crear() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await AddUbicacionService.Crear(
      city: _cityController.text,
      longitude: longitude,
      latitude: latitude,
      street: _streetController.text,
      neighborhood: _neighborhoodController.text,
      house_number: _house_numberController.text,
      state: _stateController.text,
      reference: _referenceController.text,
      image: _image!,
      maps_address: '${calle} ${ciudad} ${estado}',
    );

    Navigator.pop(context);

    if (result['success'] == true) {
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          title: "Operacion exitosa",
          message: 'ubicacion añadida',
          type: alert_type.exito,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UbicacionesPage()),
        );
      });
    } else {
      mostrarAlerta(
        context,
        title: "Error",
        message: result['message'],
        type: alert_type.error,
      );
    }
  }

  Future<void> _pickImage() async {
    final File? image = await pickAndCropImage(context);

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    obtenerCoordenadas();
  }

  bool salir() {
    if (_paginaActual != 0) {
      setState(() {
        _paginaActual--; // vuelve al formulario
      });
      return false;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  void initState() {
    super.initState();
    // 👇 SE EJECUTA AL ENTRR A LA PÁGINA
    print("Entré a Restaurantes");
    obtenerCoordenadas();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return salir();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // APPBAR
            _buildSliverAppBar(),

            // CONTENIDO
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // PÁGINA 0
                  if (_paginaActual == 1) ...[
                    _buidFormularioInfo(),
                    const SizedBox(height: 50),
                    
                  ],

                  if (_paginaActual == 0)
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height -
                          kToolbarHeight, // espacio bajo appbar
                      child: _buidFormularioUbicacion(),
                    ),
                ],
              ),
            ),
          ],
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
          salir();
        },
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Añadir Ubicación',
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
    final screenHeight = MediaQuery.of(context).size.height;
    _cityController.text = ciudad!;
    _streetController.text = calle!;
    _stateController.text = estado!;
    return KeyboardDismisser(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _streetController,
                label: 'Calle e intersecciónes',
                icon: Icons.home,
                readOnly: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su calle';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                controller: _house_numberController,
                label: 'Numero de casa o edificio',
                icon: Icons.home,
                readOnly: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su numero de casa';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _neighborhoodController,
                label: 'Colonia o Fraccionamiento',
                icon: Icons.home,
                readOnly: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su colonia';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _stateController,
                label: 'Estado ',
                icon: Icons.home,
                readOnly: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su estado';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              CustomTextFormField(
                controller: _cityController,
                label: 'Cuidad o municipio',
                icon: Icons.home,
                readOnly: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su ciudad';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Archivos adjuntos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:  Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
              _buidFormularioImg(),
              ElevatedButton(
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  if (_image == null) {
                    mostrarAlerta(
                      context,
                      title: 'Imagen requerida',
                      message: 'Por favor llena los 3 campos de imagen',
                      type: alert_type.advertencia,
                    );
                    return;
                  }
                  _Crear();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 50),
                  backgroundColor:  colorsecundario,
                  foregroundColor: colorWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Guardar', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
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
            onTap: (pos) {
              setState(() {
                posicionActual = pos;
                latitude = pos.latitude;
                longitude = pos.longitude;
              });
              getcalle();
            },

            markers: {
              Marker(
                markerId: MarkerId("ubicacion"),
                position: posicionActual!,
              ),
            },
          ),
          Positioned(
            bottom: 150,
            right: 15,
            child: FloatingActionButton(
              heroTag: "ubicacion",
              backgroundColor: colorsecundario,
              onPressed: _irAMiUbicacion,
              child: Icon(Icons.my_location, color: colorWhite),
            ),
          ),

          // PANEL SUPERIOR
          Positioned(
            top: 60,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Selecciona ubicación",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text("$calle", style: TextStyle(color: Colors.white)),
                  Text("$ciudad", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

          // BOTÓN GUARDAR
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (calle == null) {
                  mostrarAlerta(
                    context,
                    title: 'Ubicacion requerida',
                    message: 'Por favor selecciona ubicacion',
                    type: alert_type.advertencia,
                  );
                  return;
                }
                setState(() {
                  _paginaActual++;
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorsecundario,
                foregroundColor: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Siguiente',
                style: TextStyle(fontSize: 18, color: colorWhite),
              ),
            ),
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
            _image == null
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
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
            SizedBox(height: 25),
            Transform.translate(
              offset: Offset(
                80,
                -80,
              ), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
              child: Container(
                decoration: BoxDecoration(
                  color: colorsecundario,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 60,
                height: 60,
                child: IconButton(
                  onPressed: () {
                    _pickImage();
                  },
                  icon: const Icon(
                    Icons.add_a_photo_outlined,
                  ), // Usa un icono de calendario
                  color: const Color.fromARGB(255, 255, 255, 255),
                  iconSize: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
