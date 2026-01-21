import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/Nacimientoformatter.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/pages/root.dart';
import 'package:gixt/services/Auth/cuenta_service.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
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
      ciudad: "_ciudadController.text",
      longitud: 11,
      latitud: 11,
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
      mostrarAlerta(
        context,
        titulo: "Error",
        mensaje: result['message'],
        tipo: TipoAlerta.error,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar imagen',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: 'Recortar imagen',
          aspectRatioLockEnabled: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          doneButtonTitle: 'Listo',
          cancelButtonTitle: 'Cancelar',
          resetAspectRatioEnabled: false,
          rotateButtonsHidden: true,
        ),
      ],
    );

    if (croppedFile == null) return;

    setState(() {
      _image = File(croppedFile.path);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paginas = [
      _buidFormulario(),
      _buidFormularioInfo(),
      _buidFormularioImg(),
    ];
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: AutofillGroup(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: [
                _buidTitle(),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _paginaActual = i),
                    children: paginas,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(paginas.length, (i) => _dot(i)),
                ),
                SizedBox(height: 50),
              ],
            ),
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

  // ================= INPUT DECORATION =================
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

  Widget _buidTitle() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: screenHeight * 0.2),
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: colorprimario,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(0),
          ),
        ),

        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'Crear Cuenta',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: colorWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buidFormulario() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
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
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
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
      ),
    );
  }

  Widget _buidFormularioInfo() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
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
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
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
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: colorWhite),
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buidFormularioImg() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Padding(
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
                    'Foto de perfile',
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
                child: const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: TextButton.styleFrom(foregroundColor: colorWhite),
                child: const Text('Regresar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
