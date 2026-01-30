import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/Auth/Login.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/Nacimientoformatter.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/inputs/pick_image.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/pages/root.dart';
import 'package:gixt/services/Auth/cuenta_service.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class Crearcuenta extends StatefulWidget {
  const Crearcuenta({super.key});

  @override
  State<Crearcuenta> createState() => _CrearcuentaState();
}

class _CrearcuentaState extends State<Crearcuenta> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyinfo = GlobalKey<FormState>();
  final _formKeyImg = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordconfirmarController = TextEditingController();
  final _first_nameController = TextEditingController();
  final _last_nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fecha_nacimientoController = TextEditingController();
  bool _isObscured = true;
  bool _isObscured1 = true;
  final PageController _controller = PageController();
  final PreferencesService _preferencesService = PreferencesService();
  int _paginaActual = 0;
  File? _image;
  String? _genero;
  String? _token;
  String? _inicio;
  String? _id;
  String? _img;
  String? _user;
  double longitud = 0;
  double latitud = 0;
  String? calle;
  String? ciudad;
  String? estado;
  GoogleMapController? mapController;
  LatLng? posicionActual = LatLng(20.9674, -89.5926);

  Future<void> _saveToken(
    String token,
    String inicio,
    String id,
    String user,
    String img,
  ) async {
    await _preferencesService.savePreferences(token, inicio, id, img, user);
    setState(() {
      _token = token;
      _inicio = inicio;
      _id = id;
      _img = img;
      _user = user;
    });
  }

  void _Crear() async {
    if (_image == null) {
      mostrarAlerta(
        context,
        titulo: 'Imagen requerida',
        mensaje: 'Por favor selecciona una imagen de perfil',
        tipo: TipoAlerta.advertencia,
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await CuentaService.Crear(
      email: _emailController.text,
      password: _passwordController.text,
      firstName: _first_nameController.text,
      lastName: _last_nameController.text,
      imagen: _image ?? File(''),
      phone: _phoneController.text,
      ciudad: ciudad!,
      longitud: longitud,
      latitud: latitud,
      genero: _genero ?? "",
      fechaNacimiento: _fecha_nacimientoController.text,
      tokenFcm: "cfddds",
    );

    Navigator.pop(context);

    if (result['success'] == true) {
      final data = result['data'];
      String message = "Bienvenido ${data['username']}";
      Future.microtask(() async {
        await _saveToken(
          data['token'],
          "true",
          data['id'].toString(),
          data['username'],
          data['img'],
        );
        await mostrarAlerta(
          context,
          titulo: "Bienvenido",
          mensaje: message,
          tipo: TipoAlerta.exito,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RootPage()),
        );
      });
    } else {
       Future.microtask(() async {
      await mostrarAlerta(
        context,
        titulo: "Error",
        mensaje: result['message'],
        tipo: TipoAlerta.error,
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
       });
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
    } catch (e) {
      print(e);
    }
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        return salir();
      },
      child:KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (_paginaActual == 0) _buidFormulario(),
                  if (_paginaActual == 1) _buidFormularioInfo(),
                  if (_paginaActual == 2)
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        kToolbarHeight, // espacio bajo appbar
                    child: _buidFormularioUbicacion()
                  ),
                  if (_paginaActual == 3) _buidFormularioImg(),
                  if (_paginaActual != 2) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => _dot(i)),
                  ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      )
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

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: colorprimario,
      expandedHeight: 120,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 120,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(0),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
         salir();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Crear Cuenta',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }

  Widget _buidFormulario() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
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
                  'Credenciales de la cuenta',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
                const Divider(
                  color: colorWhite,
                  thickness: 2,
                  indent: 50,
                  endIndent: 50,
                ),
              ],
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              decoration: InputDecoration(
                labelText: 'Correo',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.email, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un correo';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscured,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: colorWhite),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
                border: const UnderlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: colorWhite,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordconfirmarController,
              obscureText: _isObscured1,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                labelStyle: const TextStyle(color: colorWhite),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
                border: const UnderlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured1 ? Icons.visibility : Icons.visibility_off,
                    color: colorWhite,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured1 = !_isObscured1;
                    });
                  },
                ),
              ),
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text !=
                    _passwordconfirmarController.text) {
                  mostrarAlerta(
                    context,
                    titulo: 'Las contraseñas no coinciden',
                    mensaje: 'Por favor, revisa la contraseña',
                    tipo: TipoAlerta.advertencia,
                  );
                  return;
                }
                if (!(_formKey.currentState?.validate() ?? false)) return;
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
          ],
        ),
      ),
    );
  }

  Widget _buidFormularioInfo() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: _formKeyinfo,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Informacion de la cuenta',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
                const Divider(
                  color: colorWhite,
                  thickness: 2,
                  indent: 50,
                  endIndent: 50,
                ),
              ],
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _first_nameController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.person, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _last_nameController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              decoration: InputDecoration(
                labelText: 'Apellido',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.person, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un apellido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Telefono',
                labelStyle: const TextStyle(color: colorWhite),
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),
                suffixIcon: const Icon(Icons.phone, color: colorWhite),
                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un telefono';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _fecha_nacimientoController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                FechaNacimientoFormatter(),
              ],

              decoration: const InputDecoration(
                labelText: 'Fecha de nacimiento',
                labelStyle: const TextStyle(color: colorWhite),
                hintText: 'DD/MM/AAAA',
                suffixIcon: Icon(Icons.cake, color: colorWhite),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
                ),

                errorStyle: const TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu fecha de nacimiento';
                }
                if (value.length != 10) {
                  return 'Formato inválido (DD/MM/AAAA)';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Género',
                  style: TextStyle(
                    color: colorWhite,
                    fontSize: 15,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'H',
                        groupValue: _genero,
                        activeColor: colorWhite,
                        title: const Text(
                          'Hombre',
                          style: TextStyle(color: colorWhite),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _genero = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'M',
                        groupValue: _genero,
                        activeColor: colorWhite,
                        title: const Text(
                          'Mujer',
                          style: TextStyle(color: colorWhite),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _genero = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                if (!(_formKeyinfo.currentState?.validate() ?? false)) return;
                if (_genero == null) {
                  mostrarAlerta(
                    context,
                    titulo: 'Género requerido',
                    mensaje: 'Por favor, selecciona tu género',
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
            TextButton(
              onPressed: () {
                setState(() {
                  _paginaActual--;
                });
              },
              style: TextButton.styleFrom(foregroundColor: colorWhite),
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buidFormularioImg() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeyImg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
                const Divider(
                  color: colorWhite,
                  thickness: 2,
                  indent: 50,
                  endIndent: 50,
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: [
                _image == null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 177, 177, 177),
                          borderRadius: BorderRadius.circular(100),
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
                          borderRadius: BorderRadius.circular(100),
                        ),
                        width: 200,
                        height: 200,
                        child: CircleAvatar(
                          backgroundImage: FileImage(_image!),
                        ),
                      ),
                SizedBox(height: 25),
                Transform.translate(
                  offset: Offset(
                    60,
                    -70,
                  ), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorprimario,
                      borderRadius: BorderRadius.circular(50),
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
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: _Crear,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorWhite,
                foregroundColor: colorprimario,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Crear Cuenta', style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _paginaActual--;
                });
              },
              style: TextButton.styleFrom(foregroundColor: colorWhite),
              child: const Text('Regresar'),
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

}
