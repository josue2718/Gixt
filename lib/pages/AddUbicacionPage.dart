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
  GoogleMapController? _mapController;

  double longitude = 0;
  double latitude = 0;
  int _paginaActual = 0;
  File? _image;
  String? calle;
  String? ciudad;
  String? estado;
  String? pais;
  String? colonia;
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

    // 🔥 MOVER CÁMARA
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: nuevaPos, zoom: 17),
      ),
    );

    getcalle();
  }

  void getcalle() {
    GeocodingHelper.obtenerCiudadDesdeCoordenadas(
      latitud: latitude,
      longitud: longitude,
      onResult:
          (ciudadResult, calleResult, estadoResult, paisResult, coloniaResult) {
            setState(() {
              ciudad = ciudadResult;
              calle = calleResult;
              estado = estadoResult;
              colonia = coloniaResult;
              pais = paisResult;
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
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: posicionActual!, zoom: 17),
          ),
        );
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 90,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 90,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Theme.of(context).colorScheme.surface,
        onPressed: () {
          salir();
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Añadir Ubicación',
          style: GoogleFonts.poppins(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Informacion de la ubicacion',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Asegurate de que la información sea correcta',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.45),
                ),
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
               Text(
                'Imagen de la ubicación',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Asegurate de subir una imagen clara de la ubicación, puede ser la fachada de tu casa o un punto de referencia cercano',
                 textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  height: 1.6,
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.45),
                ),
              ),
              const SizedBox(height: 20),
              _buidFormularioImg(),
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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

                  /// 🔥 ESTILO
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: colorsecundario,
                    foregroundColor: colorWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  icon: const Icon(Icons.save_outlined, size: 22),
                  label: Text(
                    'Guardar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                      color: colorWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,)
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
            onMapCreated: (controller) {
              _mapController = controller;
            },
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

              CameraUpdate.newCameraPosition(
                CameraPosition(target: pos, zoom: 17),
              );

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
                  Text("$colonia", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

          // BOTÓN GUARDAR
          Positioned(
            bottom: 90,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
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

              /// 🔥 ESTILO
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              icon: const Icon(Icons.arrow_forward, size: 22),
              label: Text(
                'Siguiente',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.6,
                  color: colorWhite,
                ),
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
      child: GestureDetector(
        onTap: () => _pickImage(),
        child: SizedBox(
          width: double.infinity,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _image == null
                  ? Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.05),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.12),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 28,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.25),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
