import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/Nacimientoformatter.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/Componets/colors.dart';
import 'package:gixt/services/User_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
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
  final ApiUser user = ApiUser();
  final ScrollController _scrollController = ScrollController();
  final _usernameController = TextEditingController();
  final _formKeyinfo = GlobalKey<FormState>();
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController(); 
  final _passwordconfirmarController = TextEditingController();
  final _first_nameController= TextEditingController();
  final _last_nameController= TextEditingController();
  final _phoneController= TextEditingController();
  final _fecha_nacimientoController= TextEditingController();
  String? _genero;

  void initState() {
    super.initState();

    // 👇 SE EJECUTA AL ENTRAR A LA PÁGINA
    print("Entré a Mi perfil");
    user.fetchData();
  }
Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');

    user.updatedata();
      hasMore = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        body: FutureBuilder(
          future: Future.wait([user.fetchData()]),
          builder: (context, snapshot) {
            if (user.user.isEmpty) {
              return  Indicador();
              
            }
            return KeyboardDismisser(
              child: Scaffold(
                appBar: _buildAppBar(), 
                backgroundColor: colorfondo,
                body:  RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: 
                SingleChildScrollView(
                  child: AutofillGroup(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildIMGPerfil(),
                          Transform.translate(
                          offset: Offset(
                            0,
                            -50,
                          ),child: 
                          _buidFormularioInfo(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
             )
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: colorprimario,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 100, // 🔥 MÁS ALTO
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(0), // 🔥 BORDES ABAJO
        ),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            'Mi Perfil',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Edita tu información personal',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: IconButton(
            icon: const Icon(Icons.notifications_none, size: 26),
            color: Colors.white,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildIMGPerfil() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(0, 103, 10, 10),
              borderRadius: BorderRadius.circular(50),
            ),
            width: 150,
            height: 150,
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.user[0].url_img),
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
                  // _pickImage();
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
    );
  }

  Widget _buildInformacion() {
    _usernameController.text = user.user[0].first_name;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Form(
        child: Container(
          child: Column(
            children: [
              Text(
                'Información Personal',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colortitulo3,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa tu nombre' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              const SizedBox(height: 30),
              Text(
                'Información de Contacto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorsecundario,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 70),
              ElevatedButton(
                onPressed: () {
                  // Acción al presionar el botón
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 50),
                  backgroundColor: colorprimario,
                  foregroundColor:colorsecundario,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Actualizar Información',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colortitulo
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: colorsecundario,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Eliminar Cuenta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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


 
  Widget _buidFormularioInfo() {
    final screenHeight = MediaQuery.of(context).size.height;
    _first_nameController.text =  user.user[0].first_name;
    _last_nameController.text = user.user[0].last_name;
    _emailController.text = user.user[0].email;
    _phoneController.text =user.user[0].phone;
    _fecha_nacimientoController.text = user.user[0].fecnac;
    _genero =user.user[0].genero;
    
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
                    'Informacion de la cuenta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                  ),
                  SizedBox(height: 10),
                 
                ]
              ),
              const SizedBox(height: 20),
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
                suffixIcon: Icon(Icons.cake ,color: colorWhite,),
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
                  'Actualizar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                    onPressed: () {
                    
                    },
                    style: TextButton.styleFrom(foregroundColor: colorWhite),
                    child: const Text('Eliminar Cuenta'),
                  ),
              SizedBox(height: 50,)
            ],
          ),
        ),
      
    );
  }

}

