import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Auth/CrearCuenta.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/input.dart';
import 'package:gixt/components/inputs/inputpassword.dart';
import 'package:gixt/services/Auth/auth_service.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _emailController =
      TextEditingController(); // Controlador para el nombre de usuario
  final _passwordController =
      TextEditingController(); // Controlador para la contraseña
  bool _isObscured = true;
  final PreferencesService _preferencesService = PreferencesService();
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

  void _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Indicador(),
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
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => RootPage()),
        // );
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

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(children: [_buildLogo(), _buildFormulario()]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Hero(
          tag: 'logo',
          child: Image.asset(
            'assets/persona.png',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: colorsecundario,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            CustomTextFormField(
              controller: _emailController,
              label: 'Correo',
              readOnly: false,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un correo';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            CustomPasswordFormField(controller: _passwordController),

            const SizedBox(height: 10),

            // Recuperar contraseña
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón de inicio de sesión
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: colorsecundario,
                foregroundColor: colorWhite,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorWhite,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botón de registro
            TextButton(
              onPressed: _handleNavigateToRegister,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'o',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorsecundario,
                  child: Image.asset(
                    'assets/google.png',
                    width: 25,
                    height: 25,
                  ),
                ),
                const SizedBox(width: 40),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorsecundario,
                  child: Image.asset('assets/apple.png', width: 25, height: 25),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su correo';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _handleForgotPassword() {
    // Implementa la lógica de recuperación de contraseña
    print('Recuperar Contraseña presionado');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
  }

  void _handleNavigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Crearcuenta()),
    );
  }
}
