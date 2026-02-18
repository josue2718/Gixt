import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gixt/Auth/Login.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/Input.dart';
import 'package:gixt/components/inputs/Input_Fecha.dart';
import 'package:gixt/components/inputs/Input_Phone.dart';
import 'package:gixt/components/inputs/Pick_Image.dart';
import 'package:gixt/pages/UbicacionesPage.dart';
import 'package:gixt/providers/theme_provider.dart';
import 'package:gixt/services/ubicaciones/geocoding_helper.dart';
import 'package:gixt/services/ubicaciones/location_service.dart';
import 'package:gixt/services/user/User_service.dart';
import 'package:gixt/services/user/update_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool isLoading = false;
  bool hasMore = true;
  final User_service user = User_service();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _first_nameController = TextEditingController();
  final _last_nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birth_dateController = TextEditingController();
  final PreferencesService _preferencesService = PreferencesService();
  String? _gender;
  String? _imageUrl;
  File? _image;
  String? _img;
  String? _user;


  Future<void> _updateUser(String user, String img) async {
    await _preferencesService.clearPreferencesUser();
    await _preferencesService.savePreferencesUser(img, user);
    setState(() {
      _img = img;
      _user = user;
    });
  }

  void initState() {
    super.initState();
    print("Entré a Mi perfil");
    _Initial();
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');
      user.updatedata();
      hasMore = true;
    });
  }

  Future<void> _Initial() async {
    bool ok = await user.fetchUserData();
    if (!ok) {
      if (!mounted) return;
      mostrarAlerta(
        context,
        title: "Error",
        message: "No se pudo obtener la información",
        type: alert_type.error,
      );
    }

    setState(() {
      print('Iniciando home');
      hasMore = true;
    });
  }

  void _logout() async {
    bool continuar = await mostrarAlerta(
      context,
      title: "Logout",
      message: 'Seguro que deseas cerrar sesión?',
      type: alert_type.advertencia,
    );
    if (!continuar) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _Crear() async {
     if (!(_formKey.currentState?.validate() ?? false)) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
    );

    final result = await UpdateService.Crear(
      first_name: _first_nameController.text,
      last_name: _last_nameController.text,
      image: _image,
      phone: _phoneController.text,
      gender: _gender ?? "",
      birth_date: _birth_dateController.text,

    );

    Navigator.pop(context);

    if (result['success'] == true) {
      final data = result['data'];
      mostrarAlerta(
        context,
        title: "Datos Actualizados",
        message: 'tus datos se actualizo correctamente',
        type: alert_type.exito,
      );
      await user.updatedata();
      _updateUser(user.user[0].username, user.user[0].image_url);
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
  Widget build(BuildContext context) {
    if (user.user.isEmpty) {
      return const Scaffold(
        body: Center(child: Indicador()),
      );
    }

    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              _buildSliverAppBar(),

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 30,
                ),

                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    const SizedBox(height: 1),

                    _buildIMGPerfil()
                        .animate()
                        .fade()
                        .slideX(begin: -0.2),

                    const SizedBox(height: 30),

                    _buildopcions()
                        .animate()
                        .fade()
                        .slideX(begin: -0.2),

                    const SizedBox(height: 10),

                    _buidFormularioInfo()
                        .animate()
                        .fade()
                        .slideX(begin: -0.2),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildopcions() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UbicacionesPage(),
                  ),
                );
              },
              child: Container(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: colorsecundario,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_location_alt, // Tu icono original
                          size: 25,
                          color: colorWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Mis Ubicaciones',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: colorsecundario,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_reset, // Tu icono original
                        size: 25,
                        color: colorWhite,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cambiar Contraseña',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _logout();
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: colorsecundario,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.logout, // Tu icono original
                          size: 25,
                          color: colorWhite,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final isDark = themeProvider.themeMode == ThemeMode.dark;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: colorsecundario,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            !isDark ? Icons.light_mode : Icons.dark_mode,
                            size: 25,
                            color: colorWhite,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      !isDark ? 'Light' : 'Dark',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 80,
      pinned: true, //  deja solo la barra pequeña visible
      floating: false, //  NO aparece al subir
      snap: false, // NO animación automática
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Mi Perfil',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: colorsecundario,
          ),
        ),
      ),
    );
  }

  Widget _buildIMGPerfil() {
    _imageUrl = "${user.user[0].image_url}";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorsecundario, width: 3),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : CachedNetworkImageProvider(_imageUrl!),
                ),
              ),
              SizedBox(height: 25),
              Positioned(
                bottom: -5,
                left: 110,
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
                    color: colorWhite,
                    iconSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buidFormularioInfo() {
    _first_nameController.text = user.user[0].first_name;
    _last_nameController.text = user.user[0].last_name;
    _emailController.text = user.user[0].email;
    _phoneController.text = user.user[0].phone;
    _birth_dateController.text = user.user[0].birth_date;
    _gender = user.user[0].gender;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informacion de la cuenta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 30),

            /// NOMBRE
            CustomTextFormField(
              controller: _first_nameController,
              label: 'Nombre',
              readOnly: false,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// APELLIDO
            CustomTextFormField(
              controller: _last_nameController,
              label: 'Apellido',
              readOnly: false,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un apellido';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// CORREO
            CustomTextFormField(
              controller: _emailController,
              label: 'Correo',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un correo';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            /// TELÉFONO
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

            /// FECHA NACIMIENTO (se queda como TextFormField por formatter)
            CustomTextFormFieldfecha(controller:_birth_dateController),

            const SizedBox(height: 20),

            /// GÉNERO
            Text(
              'Género',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 15,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'H',
                    groupValue: _gender,
                    fillColor: MaterialStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(MaterialState.selected)) {
                        return colorsecundario;
                      }
                      return Theme.of(context).colorScheme.surface;
                    }),
                    title: Text(
                      'Hombre',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _gender = value);
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
                        return colorsecundario;
                      }
                      return Theme.of(context).colorScheme.surface;
                    }),
                    title: Text(
                      'Mujer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _gender = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

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
              child: Text('Actualizar', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text(
                'Eliminar Cuenta',
                style: TextStyle(color: Theme.of(context).colorScheme.surface),
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
