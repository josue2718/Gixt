import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/Nacimientoformatter.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/categoriasoption.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/Componets/opciones.dart';
import 'package:gixt/Componets/sketor/opciones.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/pages/root.dart';
import 'package:gixt/services/Auth/categorias_service.dart';
import 'package:gixt/services/Auth/cuenta_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/services.dart';

class ExpressPage extends StatefulWidget {
  const ExpressPage({super.key});
  static bool tieneDatos = false;
  @override
  State<ExpressPage> createState() => _ExpressPageState();
}

class _ExpressPageState extends State<ExpressPage> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyinfo = GlobalKey<FormState>();
  final _formKeyImg = GlobalKey<FormState>();
  final _problemaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isObscured = true;
  bool _isObscured1 = true;
  final PageController _controller = PageController();
  final PreferencesService _preferencesService = PreferencesService();
  final ApiCategorias apicategoria = ApiCategorias();
  int? _categoriaSeleccionada;

  int _paginaActual = 0;
  List<File?> _images = List.generate(4, (_) => null);
  String? _genero;
  String? _token;
  String? _inicio;
  String? _id;
  String? _img;
  String? _user;

  void _Crear() async {
    if (_images.isEmpty) {
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

    // final result = await CuentaService.Crear(
    //   email: _emailController.text,
    //   password: _passwordController.text,
    //   firstName: _first_nameController.text,
    //   lastName: _last_nameController.text,
    //   imagen:  File(''),
    //   phone: _phoneController.text,
    //   ciudad: "_ciudadController.text",
    //   longitud: 11,
    //   latitud: 11,
    //   genero: _genero ?? "",
    //   fechaNacimiento: _fecha_nacimientoController.text,
    //   tokenFcm: "cfddds",
    // );

    Navigator.pop(context);

    // if (result['success'] == true) {
    //   final data = result['data'];
    //   String message = "Bienvenido ${data['username']}";
    //   Future.microtask(() async {
    //     await mostrarAlerta(
    //       context,
    //       titulo: "Bienvenido",
    //       mensaje: message,
    //       tipo: TipoAlerta.exito,
    //     );
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => RootPage()),
    //     );
    //   });
    // } else {
    //   mostrarAlerta(
    //     context,
    //     titulo: "Error",
    //     mensaje: result['message'],
    //     tipo: TipoAlerta.error,
    //   );
    // }
  }

  Future<void> _pickImage(int index) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return; // Canceló

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
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
        ),
      ],
    );

    if (croppedFile == null) return;

    setState(() {
      _images[index] = File(croppedFile.path);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    apicategoria.fetchEmpresaData(1);
  }

  void initState() {
    super.initState();
    // 👇 SE EJECUTA AL ENTRR A LA PÁGINA
    print("Entré a Restaurantes");
    apicategoria.fetchEmpresaData(1);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorfondo,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (_paginaActual == 0) _buidFormularioInfo(),
                if (_paginaActual == 1) _buidFormularioCategoria(),
                if (_paginaActual == 2) _buidFormularioUbicacion(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => _dot(i)),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
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
                  'Informacion del servicio Express',
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
              controller: _problemaController,
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
              controller: _descripcionController,
              style: const TextStyle(color: colorWhite),
              cursorColor: colorWhite,
              keyboardType: TextInputType.multiline,
              minLines: 4, // 👈 altura mínima
              maxLines: 6, // 👈 crece hasta aquí
              decoration: InputDecoration(
                labelText: 'Descripción del problema',
                labelStyle: const TextStyle(color: colorWhite),
                alignLabelWithHint: true, // 👈 alinea bien el label
                border: const UnderlineInputBorder(),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: colorWhite),
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
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Evidencia del problema',
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
                // if (!(_formKey.currentState?.validate() ?? false)) return;
                // if (_images.where((image) => image != null).length < 3) {
                //   mostrarAlerta(
                //     context,
                //     titulo: 'Imagen requerida',
                //     mensaje: 'Por favor llena los 3 campos de imagen',
                //     tipo: TipoAlerta.advertencia,
                //   );
                //   return;
                // }

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

            const SizedBox(height: 20),
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
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buidFormularioCategoria() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Categoría del servicio Express',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorWhite,
                ),
              ),
              const SizedBox(height: 15),
              _buildCategoriaItem(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_categoriaSeleccionada == null) {
                    mostrarAlerta(
                      context,
                      titulo: 'Categoría requerida',
                      mensaje: 'Por favor selecciona una categoría',
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
                child: const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _paginaActual--;
                  });
                },
                style: TextButton.styleFrom(foregroundColor: colorWhite),
                child: const Text('Regresar'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaItem() {
    final isLoading = apicategoria.categorias.isEmpty;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 16,
        childAspectRatio: 4,
      ),
      itemCount: isLoading ? 3 : apicategoria.categorias.length,
      itemBuilder: (context, index) {
        if (isLoading) {
          return const OptionsSkeleton();
        }
        final categoria = apicategoria.categorias[index];
        return OptionsCategorias(
          nombre: categoria.nombre,
          id: categoria.id_categoria,
          selectedId: _categoriaSeleccionada,
          onSelected: (id) {
            setState(() {
              _categoriaSeleccionada = id;
            });
          },
        );
      },
    ).animate().fade().slideX(begin: -0.2);
  }

  Widget _buidFormularioImg() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            imageBox(0),
            const SizedBox(width: 50),
            imageBox(1),
            const SizedBox(width: 50),
            imageBox(2),
            const SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  Widget imageBox(int index) {
    return Column(
      children: [
        _images[index] == null
            ? Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 177, 177, 177),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 150,
                height: 150,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person), // Usa un icono de calendario
                  color: const Color.fromARGB(255, 255, 255, 255),
                  iconSize: 65,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(0, 103, 10, 10),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 150,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(_images[index]!, fit: BoxFit.cover),
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
                _pickImage(index);
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
    );
  }
}
