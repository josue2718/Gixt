import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/Auth/Login.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/Nacimientoformatter.dart';
import 'package:gixt/components/inputs/Input.dart';
import 'package:gixt/components/inputs/Input_Fecha.dart';
import 'package:gixt/components/inputs/Input_Password.dart';
import 'package:gixt/components/inputs/Input_Phone.dart';
import 'package:gixt/components/inputs/Pick_Image.dart';
import 'package:gixt/roots/root.dart';
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
  final  _birth_dateControlle = TextEditingController();
  bool _isObscured = true;
  bool _isObscured1 = true;
  final PageController _controller = PageController();
  final PreferencesService _preferencesService = PreferencesService();
  int _paginaActual = 0;
  File? _image;
  String? _gender;
  String? _token;
  String? _inicio;
  String? _id;
  String? _img;
  String? _user;
  bool? terms;
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
        title: 'Imagen requerida',
        message: 'Por favor selecciona una imagen de perfil',
        type: alert_type.advertencia,
      );
      return;
    }
    if (!terms!) {
      mostrarAlerta(
        context,
        title: 'Términos y condiciones',
        message: 'Debes aceptar los términos y condiciones para continuar.',
        type: alert_type.advertencia,
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
      image: _image ?? File(''),
      phone: _phoneController.text,
      gender: _gender ?? "",
      birth_date:  _birth_dateControlle.text,
      terms: terms!

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
          title: "Bienvenido",
          message: message,
          type: alert_type.exito,
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
          title: "Error",
          message: result['message'],
          type: alert_type.error,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return salir();
      },
      child: KeyboardDismisser(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (_paginaActual == 0) _buidFormulario(),
                    if (_paginaActual == 1) _buidFormularioInfo(),
                    
                    if (_paginaActual == 2) _buidFormularioImg(),
                    
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) => _dot(i)),
                      ),
                    
                  ],
                ),
              ),
            ],
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
            ? colorsecundario
            : Theme.of(context).colorScheme.surface.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 120,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 120,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Theme.of(context).colorScheme.surface,
        onPressed: () {
          salir();
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Crear Cuenta',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.surface,
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
                    color: colorsecundario,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            CustomTextFormField(
              controller: _emailController,
              label: 'Correo',
              readOnly: false,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un correo';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CustomPasswordFormField(controller: _passwordController),
            const SizedBox(height: 20),
            CustomPasswordFormField(
              label: 'Confirmar Contraseña',
              controller: _passwordconfirmarController,
            ),

            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text !=
                    _passwordconfirmarController.text) {
                  mostrarAlerta(
                    context,
                    title: 'Las contraseñas no coinciden',
                    message: 'Por favor, revisa la contraseña',
                    type: alert_type.advertencia,
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
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Siguiente',
                style: TextStyle(fontSize: 18),
              ),
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
                    color: colorsecundario,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            CustomTextFormField(
              controller: _first_nameController,
              label: 'Nombre',
              readOnly: false,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un Nombre';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            CustomTextFormField(
              controller: _last_nameController,
              label: 'Apellido',
              readOnly: false,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un Apelldo';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            CustomTextFormFieldPhone(
              controller: _phoneController,
              label: 'Telefono',
              readOnly: false,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un telefono';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            CustomTextFormFieldfecha(controller:  _birth_dateControlle),

            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Género',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
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
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return Theme.of(context).colorScheme.surface;
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        groupValue: _gender,
                        activeColor: Theme.of(context).colorScheme.surface,
                        title: Text(
                          'Hombre',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _gender= value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'M',
                        groupValue: _gender,
                        fillColor: MaterialStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(MaterialState.selected)) {
                            return Theme.of(context).colorScheme.surface;
                          }
                          return Theme.of(context).colorScheme.surface;
                        }),
                        activeColor: Theme.of(context).colorScheme.surface,
                        title: Text(
                          'Mujer',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
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
                if (_gender == null) {
                  mostrarAlerta(
                    context,
                    title: 'Género requerido',
                    message: 'Por favor, selecciona tu género',
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
                foregroundColor: colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Siguiente',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                salir();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
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
                    color: colorsecundario,
                  ),
                ),
                SizedBox(height: 10),
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
                      color: colorsecundario,
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
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    value: true,
                    fillColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.surface;
                      }
                      return Theme.of(context).colorScheme.surface;
                    }),
                    groupValue: terms,
                    activeColor: Theme.of(context).colorScheme.surface,
                    title: Text(
                      'Acepto los terminos y condiciones',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        terms = value;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  child: const Text('Leer'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _Crear,
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50),
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Crear Cuenta',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                salir();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }

}
