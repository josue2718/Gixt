import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gixt/Auth/CrearCuenta.dart';
import 'package:gixt/cache.dart';
import 'package:gixt/components/Indicador.dart';
import 'package:gixt/components/alert.dart';
import 'package:gixt/components/colors.dart';
import 'package:gixt/components/inputs/input.dart';
import 'package:gixt/components/inputs/Input_Password.dart';
import 'package:gixt/roots/root.dart';
import 'package:gixt/services/Auth/auth_service.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SininternetPage extends StatefulWidget {
  const SininternetPage({super.key});
  @override
  _SinIntenertState createState() => _SinIntenertState();
}

class _SinIntenertState extends State<SininternetPage> {


  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body:  Column(
          children: [
            _buildLogo(),
          ],
        )
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

  
}
