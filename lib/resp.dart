import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Auth/Login.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/Nacimientoformatter.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/services/user/update_service.dart';
import 'package:gixt/services/user/User_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ExpressPage extends StatefulWidget {
  const ExpressPage({super.key});

  @override
  State<ExpressPage> createState() => _ExpressPageState();
}

class _ExpressPageState extends State<ExpressPage> {
  bool isLoading = false;
  bool hasMore = true;
  final ApiUser user = ApiUser();
  final ScrollController _scrollController = ScrollController();
  final _usernameController = TextEditingController();
  final _formKeyinfo = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordconfirmarController = TextEditingController();
  final _first_nameController = TextEditingController();
  final _last_nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fecha_nacimientoController = TextEditingController();
  final PreferencesService _preferencesService = PreferencesService();
  final PageController _controller = PageController();
  String? _genero;
  int _paginaActual = 0;
  String? _imageUrl;
  File? _image;
  String? _img;
  String? _user;

  Future<void> _updateUser(String user, String img) async {
    await _preferencesService.savePreferencesUser(img, user);
    setState(() {
      _img = img;
      _user = user;
    });
  }
  @override
  void initState() {
    super.initState();
    print("Entré a Mi perfil");
    user.fetchData();
       _controller.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      user.updatedata();
      hasMore = true;
    });
  }

  void _logout() async {
    bool continuar = await mostrarAlerta(
      context,
      titulo: "Logout",
      mensaje: 'Seguro que deseas cerrar sesión?',
      tipo: TipoAlerta.advertencia,
    );
    if (!continuar) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _Crear() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await UpdateService.Crear(
      firstName: _first_nameController.text,
      lastName: _last_nameController.text,
      imagen: _image,
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
      mostrarAlerta(
        context,
        titulo: "Datos Actualizados",
        mensaje: 'tus datos se actualizo correctamente',
        tipo: TipoAlerta.exito,
      );

      await user.updatedata();
      _updateUser(user.user[0].username, user.user[0].url_img);
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
  Widget build(BuildContext context) {
       final paginas = [
      _buidFormularioInfo(),
      _buidFormularioCategoria(),
      _buidFormularioUbicacion(),
    ];
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: 
         AutofillGroup(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
          
                SliverToBoxAdapter( child:  Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _paginaActual = i),
                    children: paginas,
                  ),
                ),
                ),
 SliverToBoxAdapter( child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    paginas.length,
                    (i) => _dot(i),
                  ),
                ),
 ),
                SliverToBoxAdapter( child: SizedBox(height: 50,))

                ]),
            )
          )
        
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Express',
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

  Widget _buidFormularioInfo() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Informacion del servicio Express',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _first_nameController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              decoration: InputDecoration(
                labelText: '¿Qué problema tienes?',
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
                  return 'Por favor ingrese el problema';
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
                labelText: 'Descripción del problema',
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
                  return 'Por favor ingrese la descripcion del problema';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Telefono de contacto',
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
            const SizedBox(height: 50),
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
              child: const Text('Siguiente', style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buidFormularioCategoria() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Categoría del servicio Express',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 50),
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
              child: const Text('Siguiente', style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buidFormularioUbicacion() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ubicacion del servicio Express',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorWhite,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 50),
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
              child: const Text('Siguiente', style: TextStyle(fontSize: 18)),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
