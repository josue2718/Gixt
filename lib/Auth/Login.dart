import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Auth/CrearCuenta.dart';
import 'package:gixt/Componets/Indicador.dart';
import 'package:gixt/Componets/alert.dart';
import 'package:gixt/pages/root.dart';
import 'package:gixt/services/auth_service.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../Componets/colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _emailController = TextEditingController(); // Controlador para el nombre de usuario
  final _passwordController = TextEditingController(); // Controlador para la contraseña
  bool _isObscured = true;
  void _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>  Indicador()
    );

    final result = await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    Navigator.pop(context); // cerrar loader

    if (result['success'] == true) {
      final data = result['data'];
      String message = "Bienvenido ${data['username']}";
      Future.microtask(() async {
        await mostrarAlerta(context,titulo:  "Bienvenido", mensaje:  message, tipo: TipoAlerta.exito);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RootPage()),
        );
      });
    } else {
      mostrarAlerta(context,titulo:  "Error", mensaje:  result['message'], tipo: TipoAlerta.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorfondo,
        resizeToAvoidBottomInset: true,
        body: Stack(children: [_buidlogo(), _buidFormulario()]),
      ),
    );
  }

  Widget _buidlogo() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: SvgPicture.asset(
          'assets/logo.svg',
          width: 300,
          height: 300,
          color: colorWhite,
        ),
      ),
    );
  }

  Widget _buidFormulario() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        child: AutofillGroup(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: screenHeight * 0.6),
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: colorprimario,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(60),
                topRight: Radius.circular(0),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(
                    color: colorWhite,
                    thickness: 2,
                    indent: 50,
                    endIndent: 50,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: colorWhite,
                    ),
                    textAlign: TextAlign.center,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        print('Recuperar Contraseña presionado');
                      },
                      style: TextButton.styleFrom(foregroundColor: colorWhite),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 70),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(300, 50),
                      backgroundColor: colorWhite,
                      foregroundColor: colorprimario,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Crearcuenta(),
                      ),
                    );
                    },
                    style: TextButton.styleFrom(foregroundColor: colorWhite),
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
