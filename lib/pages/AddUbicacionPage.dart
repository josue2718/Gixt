import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/inputs/pick_image.dart';
import 'package:gixt/pages/UbicacionesPage.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
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
  final _calleController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _estadoController = TextEditingController();
  final _ncasaController = TextEditingController();
  final PageController _controller = PageController();
  double longitud = 0;
  double latitud = 0;
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
      latitud = position.latitude;
      longitud = position.longitude;
    });
    getcalle();
  }

  void getcalle() {
    GeocodingHelper.obtenerCiudadDesdeCoordenadas(
      latitud: latitud,
      longitud: longitud,
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
      latitud = pos.latitude;
      longitud = pos.longitude;
      setState(() {
        posicionActual = LatLng(pos.latitude, pos.longitude);
      });
      getcalle();
    } catch (e) {
      print(e);
    }
  }

  void _Crear() async {
    

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await AddUbicacionService.Crear(

      ciudad: _ciudadController.text,
      longitud: longitud,
      latitud: latitud , 
      calle: _calleController.text, 
      colonia: _coloniaController.text,
       ncasa: _ncasaController.text, 
       estado: _estadoController.text,
        referencias: _descripcionController.text, 
        image: _image!,
        direccion_maps : '${calle} ${ciudad} ${estado}'

    );

    Navigator.pop(context);

    if (result['success'] == true) {
      
      Future.microtask(() async {
        await mostrarAlerta(
          context,
          titulo: "Operacion exitosa",
          mensaje: 'ubicacion añadida',
          tipo: TipoAlerta.exito,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UbicacionesPage()),
        );
      });
    } else {
      mostrarAlerta(
        context,
        titulo: "Error",
        mensaje: result['message'],
        tipo: TipoAlerta.error,
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

  bool salir()
  {
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
    return  WillPopScope(
      onWillPop: () async {
        return salir();
      },
      child:Scaffold(
      backgroundColor: colorfondo,
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (i) => _dot(i)),
                  ),
                  const SizedBox(height: 150),
                ],

                if (_paginaActual == 0)
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight, // espacio bajo appbar
                    child: _buidFormularioUbicacion()
                  ),
              ],
            ),
          ),
        ],
      )
      )
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
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Añadir Ubicación',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }

  Widget _dot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _paginaActual == index ? 12 : 8,
      height: _paginaActual == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _paginaActual == index
            ? colorWhite
            : colorWhite.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    VoidCallback? onIconTap,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: colorWhite),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: colorWhite),
      ),
      suffixIcon: onIconTap == null
          ? Icon(icon, color: colorWhite)
          : IconButton(
              icon: Icon(icon, color: colorWhite),
              onPressed: onIconTap,
            ),
    );
  }

  Widget _buidFormularioInfo() {
    final screenHeight = MediaQuery.of(context).size.height;
    _ciudadController.text = ciudad!;
    _calleController.text = calle!;
    _estadoController.text= estado!;
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
            ElevatedButton(
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                if (_image == null) {
                  mostrarAlerta(
                    context,
                    titulo: 'Imagen requerida',
                    mensaje: 'Por favor llena los 3 campos de imagen',
                    tipo: TipoAlerta.advertencia,
                  );
                  return;
                }
                _Crear();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorWhite,
                foregroundColor: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Guardar', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
      )
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
                latitud = pos.latitude;
                longitud = pos.longitude;
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
              backgroundColor: Colors.white,
              onPressed: _irAMiUbicacion,
              child: Icon(Icons.my_location, color: Colors.black),
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
              onPressed: ()
              {
                if (calle == null) {
                  mostrarAlerta(
                    context,
                    titulo: 'Ubicacion requerida',
                    mensaje: 'Por favor selecciona ubicacion',
                    tipo: TipoAlerta.advertencia,
                  );
                  return;
                }
                setState(() {
                  _paginaActual++;
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorWhite,
                foregroundColor: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Siguiente', style: TextStyle(fontSize: 18)),
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
                70,
                -70,
              ), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
              child: Container(
                decoration: BoxDecoration(
                  color: colorprimario,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 50,
                height: 50,
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
